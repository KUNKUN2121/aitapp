import 'package:aitapp/application/state/class_timetable/timetable_fetch_provider.dart';
import 'package:aitapp/application/usecases/session_reauth.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 時間割取得中にアプリ全体を覆い、操作を無効化する全画面オーバーレイ。
///
/// [ModalBarrier] でタブ切替・ドロワーを含む全操作をブロックし、進捗と
/// 「閉じない/スリープさせない」旨を表示する。取得開始から一定時間経過後に
/// キャンセルボタンを出す。
class TimetableFetchOverlay extends ConsumerWidget {
  const TimetableFetchOverlay({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fetch = ref.watch(timetableFetchProvider);
    // 再認証(SSO WebView)中はオーバーレイを一旦どけて、WebViewの操作を妨げない。
    final reauthing = ref.watch(reauthInProgressProvider);
    if (!fetch.isRunning || reauthing) {
      return const SizedBox.shrink();
    }
    final theme = Theme.of(context);
    final percent = (fetch.progress * 100).round();
    return Positioned.fill(
      child: Stack(
        children: [
          // 全操作をブロックするバリア
          const ModalBarrier(dismissible: false, color: Colors.black54),
          Center(
            child: Card(
              margin: const EdgeInsets.symmetric(horizontal: 40),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 28,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '時間割を取得中',
                      style: theme.textTheme.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 20),
                    // メインの進捗バー(概算%)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: fetch.progress == 0 ? null : fetch.progress,
                        minHeight: 8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$percent%',
                      style: theme.textTheme.labelLarge?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (fetch.message != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        fetch.message!,
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                    const SizedBox(height: 20),
                    Text(
                      'このままアプリを閉じたり、スリープさせないでください。',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.error,
                      ),
                    ),
                    if (fetch.canCancel) ...[
                      const SizedBox(height: 12),
                      TextButton(
                        onPressed: ref
                            .read(timetableFetchProvider.notifier)
                            .requestCancel,
                        child: const Text('キャンセル'),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
