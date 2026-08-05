import 'package:aitapp/application/state/setting_int_provider.dart';
import 'package:aitapp/application/usecases/main_drawer_usecase.dart';
import 'package:aitapp/infrastructure/database/timetable_database.dart';
import 'package:aitapp/presentation/screens/license.dart';
import 'package:aitapp/presentation/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Settings extends ConsumerWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final usecase = MainDrawerUseCase(ref, context);
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: const Text(
          '設定',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('ライセンス表示'),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (ctx) => const LicenseScreen(),
                ),
              );
            },
          ),
          ListTile(
            title: const Text('時間割の表示行数'),
            trailing: DropdownButton(
              value: ref.watch(settingIntProvider)!['classTimeTableRow'],
              items: [
                5,
                6,
                7,
              ].map((number) {
                return DropdownMenuItem<int>(
                  value: number,
                  child: Text('$number'),
                );
              }).toList(),
              onChanged: (number) {
                ref
                    .read(settingIntProvider.notifier)
                    .changeNum('classTimeTableRow', number!);
              },
            ),
          ),
          ListTile(
            title: const Text('テーマ'),
            trailing: DropdownButton(
              value: ref.watch(settingIntProvider)!['colorTheme'],
              items: [
                'システムのデフォルト',
                'ライト',
                'ダーク',
              ].asMap().entries.map((entry) {
                return DropdownMenuItem<int>(
                  value: entry.key,
                  child: Text(entry.value),
                );
              }).toList(),
              onChanged: (number) {
                ref
                    .read(settingIntProvider.notifier)
                    .changeNum('colorTheme', number!);
              },
            ),
          ),
          ListTile(
            leading: const Icon(Icons.delete),
            title: const Text('時間割データベースの削除'),
            onTap: () {
              showDialog<void>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('時間割データベースの削除'),
                    content: const Text('時間割データベースを削除しますか？'),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                        child: const Text('キャンセル'),
                      ),
                      TextButton(
                        onPressed: () {
                          TimetableDatabase.instance.deleteTimetable();
                          Navigator.of(context).pop();
                        },
                        child: const Text('削除'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.refresh),
            title: const Text('再ログイン'),
            onTap: () {
              usecase.reLogin(const LoginScreen());
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('ログアウト'),
            onTap: () => _confirmLogout(context, usecase),
          ),
        ],
      ),
    );
  }

  /// 認証情報を削除する前に確認ダイアログを表示する。
  void _confirmLogout(BuildContext context, MainDrawerUseCase usecase) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('ログアウト'),
          content: const Text('保存された認証情報を削除します。よろしいですか？'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('キャンセル'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
                usecase.removeIdentity(const LoginScreen());
              },
              child: const Text('ログアウト'),
            ),
          ],
        );
      },
    );
  }
}
