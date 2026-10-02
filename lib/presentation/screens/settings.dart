import 'package:aitapp/application/services/push_notification.dart';
import 'package:aitapp/application/state/identity_provider.dart';
import 'package:aitapp/application/state/notification_setting/notification_setting.dart';
import 'package:aitapp/application/state/setting_int_provider.dart';
import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:aitapp/application/usecases/main_drawer_usecase.dart';
import 'package:aitapp/domain/types/identity.dart';
import 'package:aitapp/infrastructure/database/timetable_database.dart';
import 'package:aitapp/presentation/screens/auth_log_screen.dart';
import 'package:aitapp/presentation/screens/license.dart';
import 'package:aitapp/presentation/screens/login.dart';
import 'package:flutter/foundation.dart';
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
          SwitchListTile(
            secondary: const Icon(Icons.notifications_outlined),
            title: const Text('通知'),
            subtitle: _NotificationSubtitle(
              enabled: ref.watch(notificationSettingNotifierProvider),
            ),
            value: ref.watch(notificationSettingNotifierProvider),
            onChanged: (enabled) {
              final userId = ref.read(identityProvider)?.id;
              ref.read(notificationSettingNotifierProvider.notifier).setEnabled(
                    userId: userId,
                    enabled: enabled,
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
          // [デバッグ限定] 仮パスワード失効を再現するテスト用ボタン。
          // release ビルドには含まれない(kDebugMode ガード)。
          if (kDebugMode) ...[
            const Divider(),
            ListTile(
              leading: const Icon(Icons.receipt_long, color: Colors.blueGrey),
              title: const Text('[Debug] 認証ログ'),
              subtitle: const Text('セッション確立/再利用/失効/再認証の時刻履歴'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (ctx) => const AuthLogScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report, color: Colors.orange),
              title: const Text('[Debug] 仮パスワードを壊す'),
              subtitle: const Text('保存PWとメモリ上のPWを無効化。直後に時間割を開くと再認証が走る'),
              onTap: () async {
                final messenger = ScaffoldMessenger.of(context);
                final current = ref.read(identityProvider);
                if (current == null) {
                  messenger.showSnackBar(
                    const SnackBar(content: Text('ログイン情報がありません')),
                  );
                  return;
                }
                // prefs と identityProvider の両方を壊さないと、起動中のアプリは
                // メモリ上の有効PWを使い続けて失効しない。
                final broken =
                    Identity(id: current.id, password: 'BROKEN_FOR_TEST');
                await ref
                    .read(sharedPreferencesProvider)
                    .setString('password', broken.password);
                ref.read(identityProvider.notifier).setIdPassword(broken);
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text('仮パスワードを無効化しました。時間割を開いて再認証を確認してください'),
                  ),
                );
              },
            ),
          ],
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

/// 通知スイッチの補足文言。ONなのに端末側の通知許可がオフの場合は警告を出す。
class _NotificationSubtitle extends StatelessWidget {
  const _NotificationSubtitle({required this.enabled});

  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return const Text('学内連絡のプッシュ通知を受け取りません');
    }
    return FutureBuilder<bool>(
      future: isSystemNotificationAuthorized(),
      builder: (context, snapshot) {
        if (snapshot.data == false) {
          return Text(
            '端末の設定でこのアプリの通知が許可されていません',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          );
        }
        return const Text('学内連絡をプッシュ通知で受け取ります');
      },
    );
  }
}
