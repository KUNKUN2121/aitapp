import 'package:aitapp/application/state/identity_provider.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:aitapp/domain/features/get_lcam_data.dart';
import 'package:aitapp/domain/types/exception.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:aitapp/infrastructure/restaccess/access_lcan.dart';
import 'package:aitapp/presentation/screens/sso_webview.dart';
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
    final navigator = navigatorKey.currentState;
    if (navigator == null) {
      return false;
    }

    ref.read(reauthInProgressProvider.notifier).state = true;
    try {
      // Entraのセッションが生きていれば、この push は自動で key を返して pop する。
      final key = await navigator.push<String>(
        MaterialPageRoute<String>(
          builder: (_) => const SsoWebViewScreen(),
        ),
      );
      if (key == null || key.isEmpty) {
        return false;
      }
      final identity = await ssoExchangeKey(key: key);
      await pref.setString('id', identity.id);
      await pref.setString('password', identity.password);
      ref.read(identityProvider.notifier).setIdPassword(identity);
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

/// [action] を実行し、セッション失効([SessionExpiredException])を検知したら
/// 一度だけ再認証してからリトライする。
///
/// [action] は内部で最新の identity(更新後の仮パスワード)を読み直すように
/// 書くこと。再認証できなかった場合は [SessionExpiredException] を再スローする。
Future<T> runWithReauth<T>(
  SessionReauthenticator reauth,
  Future<T> Function() action,
) async {
  try {
    return await action();
  } on SessionExpiredException {
    final reauthed = await reauth.reauthenticate();
    if (!reauthed) {
      rethrow;
    }
    return action();
  }
}

/// PC版LCAMにログイン済みの [GetPCLcamData] を返す。
///
/// [runWithReauth] のリトライ時に再認証で更新された仮パスワードを使う必要が
/// あるため、識別情報は呼び出しのたびに読み直す。ログイン方式の記録も併せて行う。
Future<GetPCLcamData> loginPcLcam(Ref ref) async {
  final identity = ref.read(identityProvider)!;
  final lcamData = GetPCLcamData();
  await lcamData.create(identity.id, identity.password);
  ref.read(lastLoginNotifierProvider.notifier).changeState(LastLogin.others);
  return lcamData;
}
