import 'package:aitapp/application/state/select_syllabus_filter/select_syllabus_filter.dart';
import 'package:aitapp/domain/features/get_syllabus.dart';
import 'package:aitapp/domain/types/syllabus_filters.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'syllabus_filters.g.dart';

@Riverpod(keepAlive: true)
class SyllabusFiltersNotifier extends _$SyllabusFiltersNotifier {
  @override
  SyllabusFilters? build() {
    return null;
  }

  Future<void> create(GetSyllabus getSyllabus) async {
    state = getSyllabus.filters;
    ref
        .read(selectSyllabusFilterNotifierProvider.notifier)
        .setYear(year: getSyllabus.filters.year.values.first);
  }

  Future<void> changeYear({
    required String year,
    required GetSyllabus getSyllabus,
  }) async {
    state = await getSyllabus.getRefreshFilters(year: year);
  }
}
