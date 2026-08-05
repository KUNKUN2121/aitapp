import 'package:aitapp/application/state/select_syllabus_filter/select_syllabus_filter.dart';
import 'package:aitapp/application/state/syllabus_filter/syllabus_filters.dart';
import 'package:aitapp/domain/features/get_syllabus.dart';
import 'package:aitapp/domain/types/campus.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/select_syllabus_filters.dart';
import 'package:aitapp/domain/types/semester.dart';
import 'package:aitapp/utils/to_string_or_null.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// ドロップダウンで「指定なし(フィルタ解除)」を表すセンチネル値。
const _noneFilterValue = '__none__';

class FilterDrawer extends HookConsumerWidget {
  const FilterDrawer({
    super.key,
    required this.getSyllabus,
    required this.setFilters,
  });
  final void Function({
    required SelectSyllabusFilters selectFilters,
  }) setFilters;
  final GetSyllabus getSyllabus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filtersProvider = ref.watch(syllabusFiltersNotifierProvider);
    final selectSyllabusFilters =
        useState(ref.read(selectSyllabusFilterNotifierProvider));
    List<DropdownMenuItem<String>> getDropdownMenuItem(
      Map<String, String> filters, {
      bool withNone = false,
    }) {
      return [
        if (withNone)
          const DropdownMenuItem(
            value: _noneFilterValue,
            child: Text('指定なし'),
          ),
        ...filters.entries.map(
          (entry) => DropdownMenuItem(
            value: entry.value,
            child: Text(entry.key),
          ),
        ),
      ];
    }

    void clear() {
      if (filtersProvider == null) {
        return;
      }
      final latestYear = filtersProvider.year.values.first;
      final current = selectSyllabusFilters.value;
      selectSyllabusFilters.value = current?.copyWith(
        year: latestYear,
        campus: null,
        folder: null,
        hour: null,
        semester: null,
        week: null,
      );
      // 年度が変わる場合は年度別のフィルタ候補も更新する。
      if (current?.year != latestYear) {
        ref.read(syllabusFiltersNotifierProvider.notifier).changeYear(
              year: latestYear,
              getSyllabus: getSyllabus,
            );
      }
    }

    useEffect(
      () {
        return () {
          setFilters(selectFilters: selectSyllabusFilters.value!);
        };
      },
      [],
    );

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: filtersProvider != null
              ? Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: clear,
                          child: const Text('クリア'),
                        ),
                        Text(
                          '絞り込み',
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                      ],
                    ),
                    const Divider(),
                    ListTile(
                      title: const Text('年度'),
                      trailing: DropdownButton(
                        value: selectSyllabusFilters.value?.year,
                        items: getDropdownMenuItem(filtersProvider.year),
                        onChanged: (item) {
                          selectSyllabusFilters.value = selectSyllabusFilters
                              .value
                              ?.copyWith(year: item!, folder: null);
                          ref
                              .read(
                                syllabusFiltersNotifierProvider.notifier,
                              )
                              .changeYear(
                                year: item!,
                                getSyllabus: getSyllabus,
                              );
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('学部'),
                      trailing: DropdownButton(
                        value: selectSyllabusFilters.value?.folder ??
                            _noneFilterValue,
                        items: getDropdownMenuItem(
                          filtersProvider.folder,
                          withNone: true,
                        ),
                        onChanged: (item) {
                          selectSyllabusFilters.value =
                              selectSyllabusFilters.value?.copyWith(
                            folder: item == _noneFilterValue ? null : item,
                          );
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('キャンパス'),
                      trailing: DropdownButton(
                        value: selectSyllabusFilters.value?.campus?.num
                                .toStringOrNull() ??
                            _noneFilterValue,
                        items: getDropdownMenuItem(
                          filtersProvider.campus,
                          withNone: true,
                        ),
                        onChanged: (item) {
                          selectSyllabusFilters.value =
                              selectSyllabusFilters.value?.copyWith(
                            campus: item == _noneFilterValue
                                ? null
                                : Campus.values.firstWhere(
                                    (element) => element.num.toString() == item,
                                  ),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('開講学期'),
                      trailing: DropdownButton(
                        value: selectSyllabusFilters.value?.semester?.num
                                .toStringOrNull() ??
                            _noneFilterValue,
                        items: getDropdownMenuItem(
                          filtersProvider.semester,
                          withNone: true,
                        ),
                        onChanged: (item) {
                          selectSyllabusFilters.value =
                              selectSyllabusFilters.value?.copyWith(
                            semester: item == _noneFilterValue
                                ? null
                                : Semester.values.firstWhere(
                                    (element) => element.num.toString() == item,
                                  ),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('曜日'),
                      trailing: DropdownButton(
                        value: selectSyllabusFilters.value?.week?.num
                                .toStringOrNull() ??
                            _noneFilterValue,
                        items: getDropdownMenuItem(
                          filtersProvider.week,
                          withNone: true,
                        ),
                        onChanged: (item) {
                          selectSyllabusFilters.value =
                              selectSyllabusFilters.value?.copyWith(
                            week: item == _noneFilterValue
                                ? null
                                : DayOfWeek.values.firstWhere(
                                    (element) => element.num.toString() == item,
                                  ),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('時限'),
                      trailing: DropdownButton(
                        value: selectSyllabusFilters.value?.hour
                                .toStringOrNull() ??
                            _noneFilterValue,
                        items: getDropdownMenuItem(
                          filtersProvider.hour,
                          withNone: true,
                        ),
                        onChanged: (item) {
                          selectSyllabusFilters.value =
                              selectSyllabusFilters.value?.copyWith(
                            hour: item == _noneFilterValue
                                ? null
                                : int.tryParse(item!),
                          );
                        },
                      ),
                    ),
                  ],
                )
              : const SizedBox(),
        ),
      ),
    );
  }
}
