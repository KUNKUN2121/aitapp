import 'package:aitapp/application/auth/auth_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// [AuthLog] に記録された認証イベントを新しい順に表示するデバッグ画面。
///
/// JSESSIONID・仮パスワードの実寿命や、認証エラーの原因(セッション切れ /
/// 仮パス失効)を切り分けるための調査用。設定画面のデバッグ項目から開く。
class AuthLogScreen extends StatefulWidget {
  const AuthLogScreen({super.key});

  @override
  State<AuthLogScreen> createState() => _AuthLogScreenState();
}

class _AuthLogScreenState extends State<AuthLogScreen> {
  @override
  Widget build(BuildContext context) {
    // 新しいイベントを上に表示する。
    final entries = AuthLog.entries.reversed.toList();
    return Scaffold(
      appBar: AppBar(
        title: const Text('認証ログ'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: '全体をコピー',
            onPressed: () async {
              final messenger = ScaffoldMessenger.of(context);
              await Clipboard.setData(
                ClipboardData(text: AuthLog.entries.join('\n')),
              );
              messenger.showSnackBar(
                const SnackBar(content: Text('コピーしました')),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline),
            tooltip: 'クリア',
            onPressed: () {
              AuthLog.clear();
              setState(() {});
            },
          ),
        ],
      ),
      body: entries.isEmpty
          ? const Center(child: Text('まだ記録がありません'))
          : ListView.separated(
              itemCount: entries.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) => Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: SelectableText(
                  entries[i],
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
    );
  }
}
