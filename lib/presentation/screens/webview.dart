import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/application/state/identity_provider.dart';
import 'package:aitapp/infrastructure/restaccess/access_lcan.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends ConsumerWidget {
  const WebViewScreen({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = WebViewController();
    Future<void> getLoginCookie() async {
      // cookieManagerのインスタンスを取得する
      final cookieManager = WebViewCookieManager();

      // ログイン処理後のcookieを取得する
      final cookies = await getCookie();
      final identity = ref.read(identityProvider);
      await loginLcam(
        id: identity!.id,
        password: identity.password,
        cookies: cookies,
      );

      // 以前登録されたcookieを削除する
      await cookieManager.clearCookies();

      // JSESSIONIDを注入する
      await cookieManager.setCookie(
        WebViewCookie(
          domain: origin,
          name: 'JSESSIONID',
          value: cookies.jSessionId.split(RegExp(r'[=;]'))[1],
          path: '/portalv2',
        ),
      );
      // LiveApps-Cookieを注入する
      await cookieManager.setCookie(
        WebViewCookie(
          domain: origin,
          name: 'LiveApps-Cookie',
          value: cookies.liveAppsCookie.split(RegExp(r'[=;]'))[1],
          path: '/portalv2',
        ),
      );
      // jsを有効化
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      // fetch
      await controller.loadRequest(
        Uri.parse(origin + url),
      );
    }

    getLoginCookie();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: WebViewWidget(
        controller: controller,
      ),
    );
  }
}
