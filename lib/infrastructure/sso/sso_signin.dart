import 'package:aitapp/application/config/const.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

/// [方式B] EntraID SSO を ASWebAuthenticationSession(iOS)/ Chrome Custom Tabs
/// (Android)で行い、`lamyapp://lcam?key=xxxx` のコールバックから `key` を取り出す。
///
/// 従来の埋め込みWebView(`SsoWebViewScreen`)との違い:
/// - 実ブラウザエンジンで動くため、MicrosoftのUA偽装ハックが不要。
/// - Cookieはシステム(Safari共有)側で管理され、アプリからは触れない。
///   取り出せるのはコールバックURL内の `key` のみ(スクレイピング用の
///   JSESSIONIDは従来どおり `ssoExchangeKey` 以降の自前HTTPで別途取得する)。
///
/// 戻り値:
/// - 成功: `key`(String)
/// - ユーザーがキャンセル/閉じた: null
///
/// [preferEphemeral] を true にすると Safari の共有Cookieを使わず、毎回まっさらな
/// セッションで開く。蓄積したSSO Cookieでサイレント認証が壊れた際のリカバリ用
/// (従来の mellon 400 → Cookieクリアの自己修復に相当)。
Future<String?> signInWithSso({bool preferEphemeral = false}) async {
  try {
    final result = await FlutterWebAuth2.authenticate(
      url: ssoAuthUrl,
      callbackUrlScheme: ssoCallbackScheme,
      options: FlutterWebAuth2Options(preferEphemeral: preferEphemeral),
    );
    return Uri.parse(result).queryParameters['key'];
  } on PlatformException {
    // ユーザーによるキャンセル(code: 'CANCELED')など。ログイン中断として扱う。
    return null;
  }
}
