import 'package:aitapp/application/state/identity_provider.dart';
import 'package:aitapp/application/state/last_login/last_login.dart';
import 'package:aitapp/domain/features/get_lcam_data.dart';
import 'package:aitapp/domain/types/academic_year.dart';
import 'package:aitapp/domain/types/class.dart';
import 'package:aitapp/domain/types/class_timetable_state.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/last_login.dart';
import 'package:aitapp/domain/types/semester.dart';
import 'package:aitapp/infrastructure/database/timetable_database.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'class_timetable.g.dart';

@Riverpod(keepAlive: true)
class ClassTimeTableNotifier extends _$ClassTimeTableNotifier {
  @override
  AsyncValue<ClassTimeTableState> build() {
    _loadFromDatabase();
    return const AsyncValue.loading();
  }

  Map<DayOfWeek, Map<int, Class>> get selectClassData {
    return state.value?.timetable[state.value?.selectYear ?? 0]
            ?[state.value?.selectSemester ?? Semester.early] ??
        {};
  }

  int get selectYear {
    return state.value?.selectYear ?? 0;
  }

  Semester get selectSemester {
    return state.value?.selectSemester ?? Semester.early;
  }

  void changeSelectYear(int year) {
    state = state.whenData(
      (data) => data.copyWith(selectYear: year),
    );
  }

  void changeSelectSemester(Semester semester) {
    state = state.whenData(
      (data) => data.copyWith(selectSemester: semester),
    );
  }

  /// 時間割Mapから表示用の状態を作る。
  ///
  /// 現在年度は履修が無くても必ず含め(空の時間割として表示)、年度は降順に並べる。
  /// 初期表示は最新(現在年度)・現在の学期にする。
  ClassTimeTableState _buildState(
    Map<int, Map<Semester, Map<DayOfWeek, Map<int, Class>>>> timetable,
  ) {
    final currentYear = AcademicYear.getCurrent();
    timetable.putIfAbsent(
      currentYear,
      () => {Semester.early: {}, Semester.late: {}},
    );
    final years = timetable.keys.toList()..sort((a, b) => b.compareTo(a));
    final sorted = {for (final year in years) year: timetable[year]!};
    return ClassTimeTableState(
      timetable: sorted,
      selectYear: currentYear,
      selectSemester: Semester.getCurrent(),
    );
  }

  Future<void> _loadFromDatabase() async {
    try {
      final timetable = await TimetableDatabase.instance.getTimetable();
      if (timetable.isNotEmpty) {
        state = AsyncValue.data(_buildState(timetable));
      } else {
        await fetchData();
      }
    } on Exception catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> fetchData() async {
    state = const AsyncValue.loading();
    // PC版ログイン(SP版Cookie流用)で過去の年度分も含めて時間割を取得する
    final getPCLcamData = GetPCLcamData();
    final identity = ref.read(identityProvider);
    await getPCLcamData.create(identity!.id, identity.password);
    ref.read(lastLoginNotifierProvider.notifier).changeState(LastLogin.others);
    final result = await getPCLcamData.getClassTimeTable();

    // データベースに保存
    await TimetableDatabase.instance.saveTimetable(result);

    state = AsyncValue.data(_buildState(result));
  }
}
