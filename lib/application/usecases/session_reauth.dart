import 'package:aitapp/application/auth/lcam_session.dart';
import 'package:aitapp/application/state/identity_provider.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:aitapp/domain/features/get_lcam_data.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:aitapp/infrastructure/restaccess/access_lcan.dart';
import 'package:aitapp/infrastructure/sso/sso_signin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// アプリ全体で共有するNavigator。コンテキストを持たない場所(再認証など)から
/// 画面遷移するために使う。[MaterialApp.navigatorKey] に渡す。
final navigatorKey = GlobalKey<NavigatorState>();

/// 再認証(SSO WebView表示)中かどうか。時間割取得オーバーレイはこの間だけ
/// 一時的に隠れ、WebViewの操作を妨げないようにする。
final reauthInProgressProvider = StateProvider<bool>((ref) => false);

/// セッション(仮パスワード)失効時に、学生を自動でSSO再認証させるコーディネーター。
///
/// Entraのセッションが残っている学生は、SSO WebViewを開くとMicrosoftの認証
/// プロンプト無しに自動でリダイレクトが完了し、新しい仮パスワードを取得できる。
/// 事務職員(ID/パスワード方式)は自動再認証できないため false を返す。
class SessionReauthenticator {
  SessionReauthenticator(this.ref);

  final Ref ref;

  /// 同時多発的な失効(複数フローが並行して失効)で二重にWebViewを開かないよう、
  /// 実行中は同じFutureを共有する。
  Future<bool>? _inFlight;

  /// 再認証を試みる。成功(仮パスワード更新済み)なら true。
  /// 事務職員・キャンセル・失敗時は false。
  Future<bool> reauthenticate() {
    return _inFlight ??= _run().whenComplete(() => _inFlight = null);
  }

  Future<bool> _run() async {
    final pref = ref.read(sharedPreferencesProvider);
    // 事務職員は仮パスワード方式ではないため自動再認証できない。
    if (pref.getBool('isStaff') ?? false) {
      return false;
    }

    ref.read(reauthInProgressProvider.notifier).state = true;
    try {
      // [方式B] Entraのセッションが生きていれば、ASWebAuthenticationSession は
      // ユーザー操作なし(初回のみ同意ダイアログ)で自動的に key を返す。
      final key = await signInWithSso();
      if (key == null || key.isEmpty) {
        return false;
      }
      final identity = await ssoExchangeKey(key: key);
      await pref.setString('id', identity.id);
      await pref.setString('password', identity.password);
      // 新しい仮パスワードの発行時刻を記録し、次回の先回り更新の基準にする。
      await pref.setInt(
        passwordIssuedAtKey,
        DateTime.now().millisecondsSinceEpoch,
      );
      ref.read(identityProvider.notifier).setIdPassword(identity);
      // 仮パスワードを更新したので、古いセッションは必ず無効化する。
      // 次の ensure() が新しい仮パスワードでセッションを確立し直す。
      ref.read(lcamSessionProvider.notifier).invalidate();
      return true;
    } on Exception {
      return false;
    } finally {
      ref.read(reauthInProgressProvider.notifier).state = false;
    }
  }
}

final sessionReauthenticatorProvider = Provider<SessionReauthenticator>(
  SessionReauthenticator.new,
);

/// PC版LCAMにログイン済みの [GetPCLcamData] を返す。
///
/// `LcamSession.guard` のリトライ時に再認証で更新された仮パスワードを使う必要が
/// あるため、Cookieは呼び出しのたびに `ensure()` で読み直す。ログイン方式の記録も
/// 併せて行う。
Future<GetPCLcamData> loginPcLcam(Ref ref) async {
  final cookies = await ref.read(lcamSessionProvider.notifier).ensure();
  final lcamData = GetPCLcamData();
  await lcamData.useSession(cookies);
  // PC版(時間割)取得後もお知らせキャッシュは無効化しておく。お知らせのStruts
  // トークンは別フローのため、次回お知らせを開いたら取り直す。
  ref.read(lastLoginNotifierProvider.notifier).changeState(LastLogin.others);
  return lcamData;
}
