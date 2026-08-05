import 'package:aitapp/application/state/shared_preference_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 時間割を一度でも取得したかを永続化するフラグ。
///
/// 「情報取得」ボタンを出すか通常表示にするかの判定に使う。DBの空判定だと
/// 履修0の学生に毎回ボタンが出てしまうため、取得完了そのものを記録する。
class TimetableFetchedNotifier extends StateNotifier<bool> {
  TimetableFetchedNotifier(this._pref) : super(_pref.getBool(_key) ?? false);

  static const _key = 'timetable_fetched';
  final SharedPreferences _pref;

  Future<void> markFetched() async {
    await _pref.setBool(_key, true);
    state = true;
  }
}

final timetableFetchedProvider =
    StateNotifierProvider<TimetableFetchedNotifier, bool>(
  (ref) => TimetableFetchedNotifier(ref.read(sharedPreferencesProvider)),
);
