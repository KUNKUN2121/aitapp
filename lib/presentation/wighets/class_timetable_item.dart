import 'dart:io';

import 'package:aitapp/application/config/const.dart';
import 'package:aitapp/application/state/class_timetable/class_timetable.dart';
import 'package:aitapp/application/state/setting_int_provider.dart';

import 'package:aitapp/presentation/wighets/class_grid.dart';
import 'package:aitapp/presentation/wighets/class_time_view.dart';
import 'package:aitapp/presentation/wighets/week_grid_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

// 時間割
class TimeTable extends HookConsumerWidget {
  const TimeTable({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(classTimeTableNotifierProvider);
    final settingRow = ref.watch(settingIntProvider)!['classTimeTableRow']!;
    useEffect(
      () {
        if (asyncValue.isLoading || asyncValue.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            ref.read(classTimeTableNotifierProvider.notifier).fetchData();
          });
        }
        return null;
      },
      [],
    );
    return asyncValue.when(
      loading: () => const Center(
        child: SizedBox(
          height: 25, //指定
          width: 25, //指定
          child: CircularProgressIndicator(),
        ),
      ),
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
      data: (data) => ListView(
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
                                  clas: data[week]?[i],
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
      ),
    );
  }
}
