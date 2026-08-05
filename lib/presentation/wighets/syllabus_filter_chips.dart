import 'package:aitapp/application/state/select_syllabus_filter/select_syllabus_filter.dart';
import 'package:aitapp/application/state/syllabus_filter/syllabus_filters.dart';
import 'package:aitapp/domain/types/select_syllabus_filters.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 検索画面で現在かかっているフィルタをチップで一覧表示する。
/// 年度以外のチップは × をタップすると個別に解除できる。
class SyllabusFilterChips extends ConsumerWidget {
  const SyllabusFilterChips({
    super.key,
    required this.setFilters,
  });

  final void Function({
    required SelectSyllabusFilters selectFilters,
  }) setFilters;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final select = ref.watch(selectSyllabusFilterNotifierProvider);
    final filters = ref.watch(syllabusFiltersNotifierProvider);
    if (select == null) {
      return const SizedBox.shrink();
    }

    final chips = <Widget>[];

    // 年度(常に指定されているので解除不可)
    final yearLabel = filters?.year.entries
            .firstWhereOrNull((e) => e.value == select.year)
            ?.key ??
        select.year;
    chips.add(_buildChip(context, label: yearLabel));

    // 学部
    if (select.folder != null) {
      final folderLabel = filters?.folder.entries
          .firstWhereOrNull((e) => e.value == select.folder)
          ?.key;
      if (folderLabel != null) {
        chips.add(
          _buildChip(
            context,
            label: folderLabel,
            onDeleted: () => setFilters(
              selectFilters: select.copyWith(folder: null),
            ),
          ),
        );
      }
    }

    // キャンパス
    if (select.campus != null) {
      chips.add(
        _buildChip(
          context,
          label: select.campus!.displayName,
          onDeleted: () => setFilters(
            selectFilters: select.copyWith(campus: null),
          ),
        ),
      );
    }

    // 開講学期
    if (select.semester != null) {
      chips.add(
        _buildChip(
          context,
          label: select.semester!.displayName,
          onDeleted: () => setFilters(
            selectFilters: select.copyWith(semester: null),
          ),
        ),
      );
    }

    // 曜日
    if (select.week != null) {
      chips.add(
        _buildChip(
          context,
          label: select.week!.displayName,
          onDeleted: () => setFilters(
            selectFilters: select.copyWith(week: null),
          ),
        ),
      );
    }

    // 時限
    if (select.hour != null) {
      chips.add(
        _buildChip(
          context,
          label: '${select.hour}限',
          onDeleted: () => setFilters(
            selectFilters: select.copyWith(hour: null),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          itemCount: chips.length,
          separatorBuilder: (_, __) => const SizedBox(width: 6),
          itemBuilder: (_, i) => chips[i],
        ),
      ),
    );
  }

  Widget _buildChip(
    BuildContext context, {
    required String label,
    VoidCallback? onDeleted,
  }) {
    return Center(
      child: InputChip(
        label: Text(label),
        visualDensity: VisualDensity.compact,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        onDeleted: onDeleted,
        deleteIcon:
            onDeleted == null ? null : const Icon(Icons.close, size: 16),
      ),
    );
  }
}
