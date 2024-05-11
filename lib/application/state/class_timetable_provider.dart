import 'package:aitapp/application/state/last_login_time_provider.dart';
import 'package:aitapp/domain/features/get_class_timetable.dart';
import 'package:aitapp/domain/types/class.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassTimeTableNotifier
    extends StateNotifier<AsyncValue<Map<DayOfWeek, Map<int, Class>>>> {
  ClassTimeTableNotifier() : super(const AsyncValue.loading());

  Future<void> fetchData(String id, String password, WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(lastLoginTimeProvider.notifier).updateLastLoginTime();
      });
      final result = await GetClassTimeTable().getClassTimeTable(id, password);
      state = AsyncValue.data(result);
    } on Exception catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
}

final classTimeTableProvider = StateNotifierProvider<ClassTimeTableNotifier,
    AsyncValue<Map<DayOfWeek, Map<int, Class>>>>(
  (ref) {
    return ClassTimeTableNotifier();
  },
);
