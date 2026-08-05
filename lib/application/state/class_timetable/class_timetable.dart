import 'package:aitapp/application/state/class_timetable/timetable_fetch_provider.dart';
import 'package:aitapp/application/state/class_timetable/timetable_fetched_provider.dart';
import 'package:aitapp/application/usecases/session_reauth.dart';
import 'package:aitapp/domain/types/academic_year.dart';
import 'package:aitapp/domain/types/class.dart';
import 'package:aitapp/domain/types/class_timetable_state.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/exception.dart';
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

  /// DBから読み込む。空でも自動取得はせず、空の時間割として表示する。
  /// 初回取得を促すかどうかは [timetableFetchedProvider] のフラグで判定する。
  Future<void> _loadFromDatabase() async {
    try {
      final timetable = await TimetableDatabase.instance.getTimetable();
      // アップデート前から既にデータがある既存ユーザーは取得済みとみなし、
      // 情報取得ボタンを出さない(フラグの移行)。
      if (timetable.isNotEmpty && !ref.read(timetableFetchedProvider)) {
        await ref.read(timetableFetchedProvider.notifier).markFetched();
      }
      state = AsyncValue.data(_buildState(timetable));
    } on Exception catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  Future<void> fetchData() async {
    // 進捗の分母は「(最大遡及年数 + 現在年度) × 前期/後期」の概算ステップ数。
    final fetch = ref.read(timetableFetchProvider.notifier)..start(12);
    final reauth = ref.read(sessionReauthenticatorProvider);
    state = const AsyncValue.loading();
    try {
      // PC版ログイン(SP版Cookie流用)で過去の年度分も含めて時間割を取得する。
      // 仮パスワード失効時は runWithReauth が一度だけ再認証してリトライする。
      final result = await runWithReauth(reauth, () async {
        final getPCLcamData = await loginPcLcam(ref);
        return getPCLcamData.getClassTimeTable(
          onProgress: fetch.report,
          isCancelled: () => fetch.isCancelRequested,
        );
      });

      // データベースに保存
      await TimetableDatabase.instance.saveTimetable(result);
      // 取得完了フラグを立てる(以降は情報取得ボタンを出さない)
      await ref.read(timetableFetchedProvider.notifier).markFetched();

      state = AsyncValue.data(_buildState(result));
      fetch.finish();
    } on TimetableFetchCancelledException {
      // キャンセル時はDBを触っていないため、既存の内容へ戻す。
      // (初回取得のキャンセルなら未取得のまま情報取得ボタンが再表示される)
      fetch.finish();
      await _loadFromDatabase();
    } on Exception catch (err, stack) {
      fetch.finish();
      state = AsyncValue.error(err, stack);
    }
  }
}
