import 'package:aitapp/domain/types/campus.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/semester.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'select_syllabus_filters.freezed.dart';

@freezed
class SelectSyllabusFilters with _$SelectSyllabusFilters {
  const factory SelectSyllabusFilters({
    // 年度
    required String year,
    // 学部フォルダ
    String? folder,
    // キャンパス
    Campus? campus,
    // 時限
    int? hour,
    // 曜日
    DayOfWeek? week,
    // 開講学期
    Semester? semester,
    // 検索ワード
    @Default('') String word,
  }) = _SelectSyllabusFilters;
  const SelectSyllabusFilters._();

  bool isNull() {
    return semester == null &&
        campus == null &&
        folder == null &&
        week == null &&
        hour == null &&
        word.isEmpty;
  }
}
