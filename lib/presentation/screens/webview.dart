import 'dart:io';

import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:webview_cookie_manager/webview_cookie_manager.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewScreen extends ConsumerWidget {
  const WebViewScreen({super.key, required this.url, required this.title});

  final String url;
  final String title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = WebViewController();
    final cookieManager = WebviewCookieManager();

    Future<void> getLoginCookie() async {
      final getLcamData = ref.read(getLcamDataNotifierProvider);

      // ログイン処理
      await ref.read(getLcamDataNotifierProvider.notifier).create();

      // 以前登録されたcookieを削除する
      await cookieManager.clearCookies();

      await cookieManager.setCookies([
        // JSESSIONIDを注入する
        Cookie(
          'JSESSIONID',
          getLcamData.cookies.jSessionId.split(RegExp(r'[=;]'))[1],
        )
          ..domain = origin
          ..path = '/portalv2'
          ..httpOnly = false,
        // LiveApps-Cookieを注入する
        Cookie(
          'LiveApps-Cookie',
          getLcamData.cookies.liveAppsCookie.split(RegExp(r'[=;]'))[1],
        )
          ..domain = origin
          ..path = '/portalv2'
          ..httpOnly = false,
      ]);
      // jsを有効化
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      // fetch
      await controller.loadRequest(Uri.parse('https://$origin$url'));
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
