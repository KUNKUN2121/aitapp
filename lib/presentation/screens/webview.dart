import 'dart:io';

import 'package:aitapp/application/auth/lcam_session.dart';
import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/domain/types/exception.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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
      final session = ref.read(lcamSessionProvider.notifier);

      // WebViewを開く前に、共有セッションが認証済みかを確認する。失効していれば
      // guard が復帰階段(再ログイン→SSO)を通す。未ログインのままCookieを注入して
      // 履修/成績/アンケートが開けない、という状態を防ぐ。
      try {
        await session.guard(session.verify);
      } on AuthenticationRequiredException {
        await Fluttertoast.showToast(msg: '再度ログインしてください');
        if (context.mounted) {
          Navigator.of(context).pop();
        }
        return;
      } on Exception {
        // ネットワーク等の一時的エラーはそのまま進め、WebView側の表示に委ねる。
      }

      final getLcamData = ref.read(getLcamDataNotifierProvider);

      // 復帰済みの共有セッションのCookieを取り込む。
      await ref.read(getLcamDataNotifierProvider.notifier).create();

      // 以前登録されたcookieを削除する。
      // 古いJSESSIONIDが(ポータルホストの別パス等に)残っていると、注入する
      // 認証済みセッションと二重になり、サーバが未ログイン扱いになってしまう
      // (履修/アンケート/成績が開けなくなる)。パス限定Cookieも確実に消すため
      // clearCookies で全消しする。
      //
      // 方式BではEntra(SSO)のCookieはOS側(ASWebAuthenticationSession /
      // Custom Tabs)が管理し、この webview_flutter のCookieストアには載らない。
      // よって全消ししてもサイレント再認証には影響しない。
      await cookieManager.clearCookies();

      await cookieManager.setCookies([
        // JSESSIONIDを注入する
        Cookie('JSESSIONID', getLcamData.cookies.jsessionid)
          ..domain = origin
          ..path = '/portalv2'
          ..httpOnly = false,
        // LiveApps-Cookieを注入する
        Cookie('LiveApps-Cookie', getLcamData.cookies.liveApps)
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
