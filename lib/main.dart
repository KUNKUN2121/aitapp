import 'dart:async';
import 'dart:io';

import 'package:aitapp/application/state/id_password_provider.dart';
import 'package:aitapp/application/state/setting_int_provider.dart';
import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:aitapp/infrastructure/restaccess/access_latest_version.dart';
import 'package:aitapp/presentation/dialogs/update_dialog.dart';
import 'package:aitapp/presentation/screens/login.dart';
import 'package:aitapp/presentation/screens/tabs.dart';
import 'package:aitapp/presentation/theme/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final directory = await getApplicationDocumentsDirectory();
  final plist = directory.listSync();
  for (final p in plist) {
    try {
      await p.delete();
    } on Exception {
      // ファイルの削除に失敗した場合
    }
  }
  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(
          // ここでインスタンス化し、Providerの値を上書きします
          await SharedPreferences.getInstance(),
        ),
      ],
      child: const App(),
    ),
  );
}

class App extends ConsumerWidget {
  const App({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(settingIntProvider)!['colorTheme']!;

    return MaterialApp(
      theme: buildThemeLight(),
      darkTheme: buildThemeDark(),
      themeMode: switch (themeMode) {
        0 => ThemeMode.system,
        1 => ThemeMode.light,
        2 => ThemeMode.dark,
        _ => ThemeMode.system,
      },
      home: const InitHome(),

      // localeに日本語を登録する
      supportedLocales: const [
        Locale('ja'),
      ],

      // アプリのlocaleを日本語に変更する
      locale: const Locale('ja', 'JP'),
    );
  }
}

class InitHome extends HookConsumerWidget {
  const InitHome({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future<List<String>> loadIdPass() async {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('id') ?? '';
      final password = prefs.getString('password') ?? '';
      ref.read(idPasswordProvider.notifier).setIdPassword(id, password);
      return [id, password];
    }

    Future<bool> checkVersion() async {
      final currentVersion = (await PackageInfo.fromPlatform()).version;
      try {
        final latestVersion = await getLatestVersion();
        return latestVersion != 'v$currentVersion';
      } on SocketException {
        await Fluttertoast.showToast(msg: 'インターネットに接続できません');
      } on Exception {
        await Fluttertoast.showToast(msg: 'バージョンの確認に失敗しました');
      }
      return false;
    }

    useEffect(() {
      checkVersion().then(
        (value) => value
            ? showDialog<Widget>(
                context: context,
                builder: (BuildContext ctx) {
                  return const UpdateDialog();
                },
              )
            : null,
      );
      return null;
    });

    return FutureBuilder(
      future: loadIdPass(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data?[0] != '' &&
            snapshot.data?[1] != '') {
          return const TabScreen();
        } else if (snapshot.hasData &&
            snapshot.data?[0] == '' &&
            snapshot.data?[1] == '') {
          return const LoginScreen();
        } else {
          return const SizedBox();
        }
      },
    );
  }
}
