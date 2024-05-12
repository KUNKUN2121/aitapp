import 'package:aitapp/application/state/filter_provider.dart';
import 'package:aitapp/domain/features/get_syllabus.dart';
import 'package:aitapp/domain/types/campus.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/select_filter.dart';
import 'package:aitapp/domain/types/semester.dart';
import 'package:aitapp/utils/to_string_or_null.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class FilterDrawer extends HookConsumerWidget {
  const FilterDrawer({
    super.key,
    required this.setFilters,
    required this.getSyllabus,
  });
  final void Function({
    required SelectFilters selectFilters,
  }) setFilters;
  final GetSyllabus getSyllabus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectfilters = useMemoized(() => ref.read(selectFiltersProvider));
    final filters = ref.watch(syllabusFiltersProvider);

    final selectYear = useState<String>(selectfilters!.year);
    final selectCampus =
        useState<String?>(selectfilters.campus?.num.toStringOrNull());
    final selectFaculty = useState<String?>(selectfilters.folder);
    final selectSemester =
        useState<String?>(selectfilters.semester?.num.toStringOrNull());
    final selectWeek = useState<String?>(
      selectfilters.week?.num.toStringOrNull(),
    );
    final selectHour = useState<String?>(
      selectfilters.hour.toStringOrNull(),
    );

    useEffect(
      () {
        return () {
          final submitfilter = SelectFilters(
            year: selectYear.value,
            folder: selectFaculty.value,
            campus: selectCampus.value != null
                ? Campus.values.firstWhere(
                    (element) => element.num.toString() == selectCampus.value,
                  )
                : null,
            semester: selectSemester.value != null
                ? Semester.values.firstWhere(
                    (element) {
                      return element.num.toString() == selectSemester.value;
                    },
                  )
                : null,
            week: selectWeek.value != null
                ? DayOfWeek.values.firstWhere(
                    (element) => element.num.toString() == selectWeek.value,
                  )
                : null,
            hour: int.tryParse(selectHour.value ?? ''),
          );
          if (submitfilter != selectfilters) {
            setFilters(selectFilters: submitfilter);
          }
        };
      },
      [],
    );

    void filterClear() {
      selectFaculty.value = null;
      selectCampus.value = null;
      selectSemester.value = null;
      selectWeek.value = null;
      selectHour.value = null;
    }

    Future<void> changeYear(String year) async {
      filterClear();
      ref.read(syllabusFiltersProvider.notifier).state =
          await getSyllabus.getRefreshFilters(year: year);
    }

    Widget filterListTile(
      ValueNotifier<String?> select,
      String title,
      Iterable<MapEntry<String, String>> entries,
    ) {
      return ListTile(
        title: Text(title),
        trailing: DropdownButton(
          value: select.value,
          items: [
            for (final entry in entries) ...{
              DropdownMenuItem(
                value: entry.value,
                child: Text(entry.key),
              ),
            },
          ],
          onChanged: (item) {
            select.value = item;
            if (select == selectYear) {
              changeYear(selectYear.value);
            }
          },
        ),
      );
    }

    return Drawer(
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: filterClear,
                    child: const Text('クリア'),
                  ),
                  Text(
                    '絞り込み',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
              const Divider(),
              filterListTile(
                selectYear,
                '年度',
                filters!.year.entries,
              ),
              filterListTile(
                selectFaculty,
                '学部',
                filters.folder.entries,
              ),
              filterListTile(
                selectCampus,
                'キャンパス',
                filters.campus.entries,
              ),
              filterListTile(
                selectSemester,
                '開講学期',
                filters.semester.entries,
              ),
              filterListTile(
                selectWeek,
                '曜日',
                filters.week.entries.toList(),
              ),
              filterListTile(
                selectHour,
                '時限',
                filters.hour.entries,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
