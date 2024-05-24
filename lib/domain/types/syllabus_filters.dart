import 'package:freezed_annotation/freezed_annotation.dart';
part 'syllabus_filters.freezed.dart';

@freezed
class SyllabusFilters with _$SyllabusFilters {
  const factory SyllabusFilters({
    required Map<String, String> year,
    required Map<String, String> folder,
    required Map<String, String> campus,
    required Map<String, String> week,
    required Map<String, String> hour,
    required Map<String, String> semester,
  }) = _SyllabusFilters;
}
