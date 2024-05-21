import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/domain/types/class.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ClassTimeTableNotifier
    extends StateNotifier<AsyncValue<Map<DayOfWeek, Map<int, Class>>>> {
  ClassTimeTableNotifier() : super(const AsyncValue.loading());

  Future<void> fetchData(WidgetRef ref) async {
    state = const AsyncValue.loading();
    try {
      ref
          .read(lastLoginNotifierProvider.notifier)
          .changeState(LastLogin.others);
      final getLcamData = ref.read(getLcamDataNotifierProvider);
      await ref.read(getLcamDataNotifierProvider.notifier).create();
      final result = await getLcamData.getClassTimeTable();
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
