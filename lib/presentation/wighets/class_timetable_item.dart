import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/application/state/setting_int_provider.dart';
import 'package:aitapp/domain/types/class.dart';
import 'package:aitapp/domain/types/day_of_week.dart';

import 'package:aitapp/presentation/wighets/class_grid.dart';
import 'package:aitapp/presentation/wighets/class_time_view.dart';
import 'package:aitapp/presentation/wighets/week_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 時間割
class TimeTable extends ConsumerWidget {
  const TimeTable({
    super.key,
    required this.classData,
  });
  final Map<DayOfWeek, Map<int, Class>> classData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingRow = ref.watch(settingIntProvider)!['classTimeTableRow']!;
    return ListView(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              Column(
                children: [
                  Container(
                    alignment: Alignment.centerLeft,
                    margin: const EdgeInsets.all(2),
                    height: 35,
                  ),
                  for (int i = 0; i < settingRow; i++) ...{
                    ClassTimeView(
                      start: classPeriods[i][0],
                      end: classPeriods[i][1],
                      number: i + 1,
                    ),
                  },
                ],
              ),
              const SizedBox(
                width: 4,
              ),
              Expanded(
                child: Row(
                  children: [
                    for (final week in activeWeek) ...{
                      Expanded(
                        child: Column(
                          children: [
                            WeekGridContainer(
                              dayofweek: week,
                            ),
                            for (int i = 1; i <= settingRow; i++) ...{
                              ClassGridContainer(
                                dayOfWeek: week,
                                classPeriod: i,
                                clas: classData[week]?[i],
                              ),
                            },
                          ],
                        ),
                      ),
                    },
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
