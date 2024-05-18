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
      Map<String, String> filters,
    ) {
      return filters.entries
          .map(
            (entry) => DropdownMenuItem(
              value: entry.value,
              child: Text(entry.key),
            ),
          )
          .toList();
    }

    void clear() {
      selectSyllabusFilters.value = selectSyllabusFilters.value?.copyWith(
        campus: null,
        folder: null,
        hour: null,
        semester: null,
        week: null,
      );
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
                        value: selectSyllabusFilters.value?.folder,
                        items: getDropdownMenuItem(filtersProvider.folder),
                        onChanged: (item) {
                          selectSyllabusFilters.value = selectSyllabusFilters
                              .value
                              ?.copyWith(folder: item);
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('キャンパス'),
                      trailing: DropdownButton(
                        value: selectSyllabusFilters.value?.campus?.num
                            .toStringOrNull(),
                        items: getDropdownMenuItem(filtersProvider.campus),
                        onChanged: (item) {
                          selectSyllabusFilters.value =
                              selectSyllabusFilters.value?.copyWith(
                            campus: Campus.values.firstWhere(
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
                            .toStringOrNull(),
                        items: getDropdownMenuItem(filtersProvider.semester),
                        onChanged: (item) {
                          selectSyllabusFilters.value =
                              selectSyllabusFilters.value?.copyWith(
                            semester: Semester.values.firstWhere(
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
                            .toStringOrNull(),
                        items: getDropdownMenuItem(filtersProvider.week),
                        onChanged: (item) {
                          selectSyllabusFilters.value =
                              selectSyllabusFilters.value?.copyWith(
                            week: DayOfWeek.values.firstWhere(
                              (element) => element.num.toString() == item,
                            ),
                          );
                        },
                      ),
                    ),
                    ListTile(
                      title: const Text('時限'),
                      trailing: DropdownButton(
                        value:
                            selectSyllabusFilters.value?.hour.toStringOrNull(),
                        items: getDropdownMenuItem(filtersProvider.hour),
                        onChanged: (item) {
                          selectSyllabusFilters.value =
                              selectSyllabusFilters.value?.copyWith(
                            hour: int.tryParse(item!),
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
