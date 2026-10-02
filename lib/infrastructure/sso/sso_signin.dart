import 'package:aitapp/application/config/const.dart';
import 'package:flutter/services.dart';
import 'package:flutter_web_auth_2/flutter_web_auth_2.dart';

/// [方式B] EntraID SSO を ASWebAuthenticationSession(iOS)/ Chrome Custom Tabs
/// (Android)で行い、`lamyapp://lcam?key=xxxx` のコールバックから `key` を取り出す。
///
/// - 実ブラウザエンジンで動くため、MicrosoftのUA偽装ハックが不要。
/// - Cookieはシステム(Safari共有)側で管理され、アプリからは触れない。
///   取り出せるのはコールバックURL内の `key` のみ(スクレイピング用の
///   JSESSIONIDは `ssoExchangeKey` 以降の自前HTTPで別途取得する)。
///
/// 戻り値:
/// - 成功: `key`(String)
/// - ユーザーがキャンセル/閉じた: null
Future<String?> signInWithSso() async {
  try {
    final result = await FlutterWebAuth2.authenticate(
      url: ssoAuthUrl,
      callbackUrlScheme: ssoCallbackScheme,
    );
    return Uri.parse(result).queryParameters['key'];
  } on PlatformException {
    // ユーザーによるキャンセル(code: 'CANCELED')など。ログイン中断として扱う。
    return null;
  }
}
