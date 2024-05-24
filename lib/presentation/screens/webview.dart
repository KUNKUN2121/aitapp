import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
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
    final cookieManager = WebViewCookieManager.fromPlatformCreationParams(
      const PlatformWebViewCookieManagerCreationParams(),
    ).platform;
    Future<void> getLoginCookie() async {
      // getLcamDataを取得
      final getLcamDataNotifier =
          ref.read(getLcamDataNotifierProvider.notifier);
      final getLcamData = ref.read(getLcamDataNotifierProvider);

      // ログイン処理
      await getLcamDataNotifier.create();

      // 以前登録されたcookieを削除する
      await cookieManager.clearCookies();

      // JSESSIONIDを注入する
      await cookieManager.setCookie(
        WebViewCookie(
          domain: origin,
          name: 'JSESSIONID',
          value: getLcamData.cookies.jSessionId.split(RegExp(r'[=;]'))[1],
          path: '/portalv2',
        ),
      );
      // LiveApps-Cookieを注入する
      await cookieManager.setCookie(
        WebViewCookie(
          domain: origin,
          name: 'LiveApps-Cookie',
          value: getLcamData.cookies.liveAppsCookie.split(RegExp(r'[=;]'))[1],
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
