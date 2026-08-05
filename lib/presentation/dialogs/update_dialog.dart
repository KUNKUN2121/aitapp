import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

/// 「後で」を押したときにアップデート通知を抑制する日数。
const updateSnoozeDays = 5;

/// アップデート通知を再表示しない期限(millisecondsSinceEpoch)を保存するキー。
const updateSnoozeUntilKey = 'updateSnoozeUntil';

class UpdateDialog extends ConsumerWidget {
  const UpdateDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AlertDialog(
      title: const Text(
        'アプリのアップデートがあります',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
      ),
      actions: <Widget>[
        // ボタン領域
        ElevatedButton(
          child: const Text('$updateSnoozeDays日間通知しない'),
          onPressed: () async {
            final prefs = ref.read(sharedPreferencesProvider);
            final snoozeUntil = DateTime.now()
                .add(const Duration(days: updateSnoozeDays))
                .millisecondsSinceEpoch;
            await prefs.setInt(updateSnoozeUntilKey, snoozeUntil);
            if (context.mounted) {
              Navigator.pop(context);
            }
          },
        ),
        ElevatedButton(
          child: const Text('OK'),
          onPressed: () {
            launchUrl(
              Uri.parse(
                'https://github.com/piman528/aitapp/releases/latest',
              ),
            );
          },
        ),
      ],
    );
  }
}
