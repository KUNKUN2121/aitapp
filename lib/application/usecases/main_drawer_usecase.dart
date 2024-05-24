import 'package:aitapp/application/state/identity_provider.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/application/state/link_tap_provider.dart';
import 'package:aitapp/application/state/select_syllabus_filter/select_syllabus_filter.dart';
import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:aitapp/env.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';

class MainDrawerUseCase {
  MainDrawerUseCase(this.ref, this.context);
  final WidgetRef ref;
  final BuildContext context;

  Future<void> go(Widget widget) async {
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (ctx) => widget,
      ),
    );
  }

  Future<void> _replaceGo(Widget widget) async {
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (ctx) => widget,
      ),
    );
  }

  Future<void> removeIdentity(Widget widget) async {
    final pref = ref.read(sharedPreferencesProvider);
    await pref.remove('id');
    await pref.remove('password');
    ref.read(identityProvider.notifier).clear();
    await _replaceGo(widget);
  }

  Future<void> loginCampus({
    required bool isMoodle,
  }) async {
    if (!isMoodle) {
      ref.read(linkTapProvider.notifier).state = true;
    }
    final controller = WebViewController();
    final identity = ref.read(identityProvider);
    // jsを有効化
    await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    // htmlを読み込み
    await controller.loadFlutterAsset('assets/html/index.html');
    final date = DateFormat('yyyyMMddHHmm')
        .format(DateTime.now().toUtc().add(const Duration(hours: 9)));
    await controller.setNavigationDelegate(
      NavigationDelegate(
        onPageFinished: (url) async {
          // paraを取得
          final ciphertext = await controller.runJavaScriptReturningResult(
            // ignore: lines_longer_than_80_chars
            "getPara('$date','${identity!.id}','${identity.password}','${isMoodle ? 'Y' : 'N'}','${Env.blowfishKey}');",
          );
          await launchUrl(
            mode: LaunchMode.externalApplication,
            Uri(
              scheme: 'https',
              host: 'lcam.aitech.ac.jp',
              path: 'portalv2/login/preLogin/preSpAppSso',
              queryParameters: {
                'spAppSso': 'Y',
                'selectLocale': 'ja',
                'para': ciphertext,
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> openSyllabusSearch(Widget widget) async {
    await go(widget);
    ref.read(selectSyllabusFilterNotifierProvider.notifier).initialize();
  }

  Future<void> openWebView(Widget widget) async {
    await go(widget);
    ref.read(lastLoginNotifierProvider.notifier).changeState(LastLogin.others);
  }
}
