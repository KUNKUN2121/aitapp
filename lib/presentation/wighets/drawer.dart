// ignore_for_file: lines_longer_than_80_chars

import 'package:aitapp/application/state/id_password_provider.dart';
import 'package:aitapp/application/state/last_login_time_provider.dart';
import 'package:aitapp/application/state/link_tap_provider.dart';
import 'package:aitapp/application/state/select_syllabus_filter/select_syllabus_filter.dart';
import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:aitapp/env.dart';
import 'package:aitapp/presentation/screens/campus_map.dart';
import 'package:aitapp/presentation/screens/contacts.dart';
import 'package:aitapp/presentation/screens/course_registration.dart';
import 'package:aitapp/presentation/screens/links.dart';
import 'package:aitapp/presentation/screens/login.dart';
import 'package:aitapp/presentation/screens/open_asset_pdf.dart';
import 'package:aitapp/presentation/screens/settings.dart';
import 'package:aitapp/presentation/screens/syllabus_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class MainDrawer extends ConsumerWidget {
  const MainDrawer({super.key});

  Future<void> loginCampus({
    required WidgetRef ref,
    required String isMoodle,
  }) async {
    late final InAppWebViewController webviewcontroller;
    late final HeadlessInAppWebView headlessWebView;
    final identity = ref.read(idPasswordProvider);
    headlessWebView = HeadlessInAppWebView(
      initialFile: 'assets/html/index.html',
      onWebViewCreated: (InAppWebViewController webViewController) {
        webviewcontroller = webViewController;
        // Javascriptからの処理を登録
        webViewController.addJavaScriptHandler(
          handlerName: 'return',
          callback: (ciphertext) {
            launchUrl(
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
            headlessWebView.dispose();
          },
        );
      },
      onLoadStop: (controller, url) async {
        final date = DateFormat('yyyyMMddHHmm')
            .format(DateTime.now().toUtc().add(const Duration(hours: 9)));
        await webviewcontroller.evaluateJavascript(
          source:
              "getPara('$date','${identity[0]}','${identity[1]}','$isMoodle','${Env.blowfishKey}');",
        );
      },
    );
    await headlessWebView.run();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: ListView(
            children: [
              DrawerTile(
                icon: Icons.calendar_today,
                title: '行事予定',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => const OpenAssetPdf(
                        title: '行事予定',
                        path: 'assets/pdfs/annual-events.pdf',
                      ),
                    ),
                  );
                },
              ),
              DrawerTile(
                icon: Icons.book,
                title: '学生便覧',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => const OpenAssetPdf(
                        title: '学生便覧',
                        path: 'assets/pdfs/binran2024.pdf',
                      ),
                    ),
                  );
                },
              ),
              DrawerTile(
                icon: Icons.map_rounded,
                title: '学内マップ',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => const CampusMap(),
                    ),
                  );
                },
              ),
              DrawerTile(
                icon: Icons.search,
                title: 'シラバス検索',
                onTap: () async {
                  await Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => SyllabusSearchScreen(),
                    ),
                  );
                  ref
                      .read(selectSyllabusFilterNotifierProvider.notifier)
                      .initialize();
                },
              ),
              DrawerTile(
                icon: Icons.link,
                title: 'L-Cam',
                onTap: () async {
                  ref.read(linkTapProvider.notifier).state = true;
                  await loginCampus(ref: ref, isMoodle: 'N');
                },
              ),
              DrawerTile(
                icon: Icons.link,
                title: 'Moodle',
                onTap: () async {
                  ref.read(linkTapProvider.notifier).state = true;
                  await loginCampus(ref: ref, isMoodle: 'Y');
                },
              ),
              const Divider(),
              DrawerTile(
                icon: Icons.event,
                title: '履修/アンケート/成績',
                onTap: () {
                  Navigator.of(context)
                      .push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => const CourseRegistration(),
                    ),
                  )
                      .then((value) {
                    ref
                        .read(lastLoginTimeProvider.notifier)
                        .updateLastLoginTime();
                  });
                },
              ),
              DrawerTile(
                icon: Icons.link,
                title: '各種リンク',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => const Links(),
                    ),
                  );
                },
              ),
              DrawerTile(
                icon: Icons.phone,
                title: '各所連絡先',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => const Contacts(),
                    ),
                  );
                },
              ),
              const Divider(),
              DrawerTile(
                icon: Icons.settings,
                title: '設定',
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (ctx) => const Settings(),
                    ),
                  );
                },
              ),
              DrawerTile(
                icon: Icons.logout,
                title: 'ログアウト',
                onTap: () async {
                  final pref = ref.read(sharedPreferencesProvider);
                  await pref.remove('id');
                  await pref.remove('password').then(
                    (value) {
                      ref
                          .read(idPasswordProvider.notifier)
                          .setIdPassword('', '');
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute<void>(
                          builder: (ctx) => const LoginScreen(),
                        ),
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DrawerTile extends StatelessWidget {
  const DrawerTile({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final void Function()? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: onTap,
    );
  }
}
