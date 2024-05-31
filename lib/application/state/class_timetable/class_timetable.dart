import 'package:aitapp/application/state/get_lcam_data/get_lcam_data.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/domain/types/class.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'class_timetable.g.dart';

@Riverpod(keepAlive: true)
class ClassTimeTableNotifier extends _$ClassTimeTableNotifier {
  @override
  AsyncValue<Map<DayOfWeek, Map<int, Class>>> build() {
    fetchData();
    return const AsyncValue.loading();
  }

  Future<void> fetchData() async {
    state = const AsyncValue.loading();
    try {
      final getLcamData = ref.read(getLcamDataNotifierProvider);
      await ref.read(getLcamDataNotifierProvider.notifier).create();
      ref
          .read(lastLoginNotifierProvider.notifier)
          .changeState(LastLogin.others);
      final result = await getLcamData.getClassTimeTable();
      state = AsyncValue.data(result);
    } on Exception catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }
}
