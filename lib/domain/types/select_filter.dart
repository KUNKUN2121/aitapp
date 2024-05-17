import 'package:aitapp/domain/types/campus.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/semester.dart';

// 選択シラバスフィルタ
class SelectFilters {
  SelectFilters({
    required this.year,
    this.folder,
    this.campus,
    this.hour,
    this.week,
    this.semester,
  });
  final String year;
  final String? folder;
  final Campus? campus;
  final DayOfWeek? week;
  final int? hour;
  final Semester? semester;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }

    return other is SelectFilters &&
        other.year == year &&
        other.folder == folder &&
        other.campus == campus &&
        other.semester == semester &&
        other.week == week &&
        other.hour == hour;
  }

  @override
  int get hashCode =>
      year.hashCode ^
      folder.hashCode ^
      campus.hashCode ^
      semester.hashCode ^
      week.hashCode ^
      hour.hashCode;
}
