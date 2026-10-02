import 'package:aitapp/application/auth/auth_log.dart';
import 'package:aitapp/application/state/identity_provider.dart';
import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:aitapp/application/usecases/session_reauth.dart';
import 'package:aitapp/domain/features/lcam_parse.dart';
import 'package:aitapp/domain/types/cookies.dart';
import 'package:aitapp/domain/types/exception.dart';
import 'package:aitapp/infrastructure/restaccess/access_lcan.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lcam_session.g.dart';

/// 仮パスワードの先回り更新をかける経過時間のしきい値。
///
/// 仮パスは発行から12時間で失効するため、それより手前でアクセスがあれば
/// サイレント再認証で更新し、12時間ぎりぎりでの失敗を減らす。
const _credentialRefreshThreshold = Duration(hours: 11);

/// 仮パスワードの発行時刻を保存するSharedPreferencesのキー。
const passwordIssuedAtKey = 'passwordIssuedAt';

/// アプリ内で唯一のLCAMセッション(JSESSIONID)の所有者。
///
/// LCAMは同一ユーザーで有効なJSESSIONIDが1本しかなく、別々にログインすると
/// 後から確立したセッションが先のものを無効化してしまう。そのため
/// お知らせ・時間割・WebView など全機能はこの [LcamSession] が確立した1本の
/// Cookieを共有する。
///
/// - [ensure] : 有効なセッションがあれば再利用し、無ければ確立する。並行呼び出しは
///   single-flight で1回のログインに束ねる。
/// - [invalidate] : セッションが失効した(サーバが未ログインを返した/仮パスワードを
///   更新した)ときに破棄する。次の [ensure] で確立し直される。
@Riverpod(keepAlive: true)
class LcamSession extends _$LcamSession {
  /// 確立処理中のFuture。並行する [ensure] 呼び出しを1本に束ねるために共有する。
  Future<Cookies>? _inFlight;

  @override
  Cookies? build() => null;

  /// 有効なセッションのCookieを返す。
  ///
  /// 既存のセッションがあればそれを再利用する([forceNew] で強制的に取り直す)。
  /// これにより画面遷移のたびに新しいJSESSIONIDが発行され、前のセッションが
  /// 無効化される問題を防ぐ。
  Future<Cookies> ensure({bool forceNew = false}) async {
    // 仮パスが古ければアクセス前にサイレント更新しておく(12時間失効の先回り)。
    await _refreshCredentialIfStale();
    final cached = state;
    if (!forceNew && cached != null) {
      AuthLog.record(AuthEvent.reuse);
      return cached;
    }
    return _inFlight ??= _establish().whenComplete(() => _inFlight = null);
  }

  /// getCookie → smartPhoneLogin でセッションを確立する。
  ///
  /// ログインの成否(仮パスワード失効など)はここでは判定しない。従来どおり、
  /// 後続のスクレイピングで未ログインページを検知した時点で
  /// `SessionExpiredException` として扱い、[invalidate] → 再認証 → [ensure] で
  /// 復帰する。
  Future<Cookies> _establish() async {
    final identity = ref.read(identityProvider);
    if (identity == null) {
      throw StateError('identity が未設定のためセッションを確立できません');
    }
    final cookies = await getCookie();
    await loginLcam(
      id: identity.id,
      password: identity.password,
      cookies: cookies,
    );
    state = cookies;
    AuthLog.record(AuthEvent.establish);
    return cookies;
  }

  /// 保持しているセッションを破棄する。次の [ensure] で確立し直される。
  void invalidate() {
    if (state != null) {
      AuthLog.record(AuthEvent.invalidate);
    }
    state = null;
  }

  /// [body] を実行し、セッション無効([SessionExpiredException])を検知したら
  /// 一度だけ [recover] してからリトライする。
  ///
  /// [body] は内部で最新のセッション/仮パスワードを読み直すこと(例: `ensure()` や
  /// `create()` を呼ぶ)。復帰できなければ [AuthenticationRequiredException] が
  /// [recover] から伝播する。
  Future<T> guard<T>(Future<T> Function() body) async {
    try {
      return await body();
    } on SessionExpiredException {
      await recover();
      return body();
    }
  }

  /// 現在のセッションが認証済みかを軽量GET(ポータルトップ)で確認する。
  ///
  /// 未ログインページが返れば [SessionExpiredException] を投げる。WebViewを開く前に
  /// `guard(session.verify)` として通すことで、失効したまま未ログインページを
  /// 表示してしまうのを防ぎ、[recover] で自動復帰させる。
  Future<void> verify() async {
    final cookies = await ensure();
    final body = await getPortalTop(cookies: cookies);
    if (isNotLoggedInPage(body)) {
      throw const SessionExpiredException();
    }
  }

  /// セッション無効時の復帰階段。
  ///
  /// 1. 保存済みのid/仮パスワードで再ログインを試す(JSESSIONIDが切れただけなら
  ///    これで復帰する。事務職員もこの段で復帰できる)。
  /// 2. それでも未ログインなら仮パスワード失効とみなし、学生はSSO再認証で新しい
  ///    仮パスワードを取得して再ログインする。
  /// 3. どちらも駄目なら [AuthenticationRequiredException] を投げる(UIはログイン画面へ)。
  Future<void> recover() async {
    invalidate();
    try {
      await _establishChecked();
      AuthLog.record(AuthEvent.recoverRelogin);
      return;
    } on CredentialExpiredException {
      // 仮パスワード失効 → SSO再認証へ進む。
      AuthLog.record(AuthEvent.credentialExpired);
    }

    final reauthed =
        await ref.read(sessionReauthenticatorProvider).reauthenticate();
    if (!reauthed) {
      AuthLog.record(AuthEvent.authRequired, 'reauth failed');
      throw const AuthenticationRequiredException();
    }
    try {
      await _establishChecked();
      AuthLog.record(AuthEvent.recoverSso);
    } on CredentialExpiredException {
      // 再認証直後なのに未ログイン = 想定外。ログイン画面へ委ねる。
      AuthLog.record(AuthEvent.authRequired, 'still expired after reauth');
      throw const AuthenticationRequiredException();
    }
  }

  /// [_establish] と同じ手順でログインし、**成否を判定する**版。
  ///
  /// 未ログインページが返れば([LcamParse.isLogin] が false)、仮パスワード失効
  /// とみなして [CredentialExpiredException] を投げる。identity未設定なら
  /// [AuthenticationRequiredException]。
  Future<Cookies> _establishChecked() async {
    final identity = ref.read(identityProvider);
    if (identity == null) {
      throw const AuthenticationRequiredException();
    }
    final cookies = await getCookie();
    final body = await loginLcam(
      id: identity.id,
      password: identity.password,
      cookies: cookies,
    );
    if (!LcamParse().isLogin(body)) {
      throw const CredentialExpiredException();
    }
    state = cookies;
    return cookies;
  }

  /// 仮パスワードが発行から [_credentialRefreshThreshold] 以上経っていれば、
  /// アクセス前にサイレント再認証で更新する(12時間失効の先回り)。
  ///
  /// 事務職員(恒久パスワード)・発行時刻が未記録・しきい値未満のときは何もしない。
  /// 更新に失敗しても通常フロー(失効検知→[recover])に委ねるため、例外は握りつぶす。
  Future<void> _refreshCredentialIfStale() async {
    final pref = ref.read(sharedPreferencesProvider);
    if (pref.getBool('isStaff') ?? false) {
      return;
    }
    final issuedAt = pref.getInt(passwordIssuedAtKey);
    if (issuedAt == null) {
      return;
    }
    final age = DateTime.now().millisecondsSinceEpoch - issuedAt;
    if (age < _credentialRefreshThreshold.inMilliseconds) {
      return;
    }
    AuthLog.record(AuthEvent.prefetchRefresh);
    // reauthenticate 内で仮パス更新・passwordIssuedAt更新・invalidate まで行う。
    await ref.read(sessionReauthenticatorProvider).reauthenticate();
  }
}
