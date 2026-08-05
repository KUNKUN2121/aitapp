import 'dart:io';

import 'package:aitapp/application/state/class_timetable/class_timetable.dart';
import 'package:aitapp/application/state/class_timetable/timetable_fetched_provider.dart';
import 'package:aitapp/domain/types/semester.dart';
import 'package:aitapp/presentation/wighets/appbar.dart';
import 'package:aitapp/presentation/wighets/class_timetable_item.dart';
import 'package:aitapp/presentation/wighets/loading/timetable_loading.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ClassTimeTableScreen extends ConsumerWidget {
  const ClassTimeTableScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(classTimeTableNotifierProvider);
    final notifier = ref.read(classTimeTableNotifierProvider.notifier);
    final fetched = ref.watch(timetableFetchedProvider);
    // 一度も取得していない場合は自動取得せず、情報取得ボタンを表示する。
    if (!fetched) {
      return _InitialFetchPrompt(onFetch: notifier.fetchData);
    }
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 100),
      child: asyncValue.when(
        loading: () => const TimetableLoadingWidget(),
        error: (error, __) {
          if (error is SocketException) {
            return const Center(
              child: Text('インターネットに接続できません'),
            );
          } else {
            return Center(
              child: Text(error.toString()),
            );
          }
        },
        data: (data) => Column(
          children: [
            AppBarWidget(
              child: DefaultTabController(
                length: 2,
                initialIndex: data.selectSemester == Semester.early ? 0 : 1,
                child: Row(
                  children: [
                    Material(
                      color: Colors.transparent,
                      child: PopupMenuButton<int>(
                        initialValue: data.selectYear,
                        position: PopupMenuPosition.under,
                        surfaceTintColor: Theme.of(context).colorScheme.surface,
                        itemBuilder: (context) => data.timetable.keys
                            .map(
                              (year) => PopupMenuItem<int>(
                                value: year,
                                child: Text('$year年度'),
                              ),
                            )
                            .toList(),
                        onSelected: notifier.changeSelectYear,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                '${data.selectYear}年度',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.w600,
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                              const SizedBox(width: 4),
                              Icon(
                                Icons.arrow_drop_down,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicator: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .shadow
                                    .withValues(alpha: 0.1),
                                blurRadius: 4,
                                offset: const Offset(0, 1),
                              ),
                            ],
                          ),
                          labelPadding: EdgeInsets.zero,
                          labelColor: Theme.of(context).colorScheme.onPrimary,
                          unselectedLabelColor: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.8),
                          labelStyle:
                              const TextStyle(fontWeight: FontWeight.w600),
                          unselectedLabelStyle:
                              const TextStyle(fontWeight: FontWeight.normal),
                          tabs: [
                            Tab(
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  Semester.early.displayName,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                            Tab(
                              child: Container(
                                width: double.infinity,
                                alignment: Alignment.center,
                                child: Text(
                                  Semester.late.displayName,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ),
                          ],
                          onTap: (index) {
                            notifier.changeSelectSemester(
                              [Semester.early, Semester.late][index],
                            );
                          },
                        ),
                      ),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      tooltip: '再取得',
                      icon: Icon(
                        Icons.refresh,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      onPressed: () =>
                          _confirmRefetch(context, notifier.fetchData),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            Expanded(
              child: TimeTable(
                classData: notifier.selectClassData,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 再取得の前に確認ダイアログを表示する。時間がかかる旨を伝える。
void _confirmRefetch(BuildContext context, Future<void> Function() onRefetch) {
  showDialog<void>(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('時間割を再取得'),
        content: const Text(
          '過去の年度分も含めて取得し直すため、完了まで時間がかかります。'
          '取得中はアプリを閉じたりスリープさせないでください。よろしいですか？',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('キャンセル'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              onRefetch();
            },
            child: const Text('再取得'),
          ),
        ],
      );
    },
  );
}

/// 初回の時間割取得を促す画面。ボタンを押すと取得が始まる。
class _InitialFetchPrompt extends StatelessWidget {
  const _InitialFetchPrompt({required this.onFetch});

  final Future<void> Function() onFetch;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              '時間割を取得しましょう',
              style: theme.textTheme.titleMedium
                  ?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              '過去の年度分も含めて取得するため、完了まで少し時間がかかります。'
              '取得中はアプリを閉じたりスリープさせないでください。',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: onFetch,
              icon: const Icon(Icons.download),
              label: const Text('情報取得'),
            ),
          ],
        ),
      ),
    );
  }
}
