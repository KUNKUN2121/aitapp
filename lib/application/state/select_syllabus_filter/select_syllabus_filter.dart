import 'package:aitapp/application/state/syllabus_filter/syllabus_filters.dart';
import 'package:aitapp/domain/types/select_syllabus_filters.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
part 'select_syllabus_filter.g.dart';

@Riverpod(keepAlive: true)
class SelectSyllabusFilterNotifier extends _$SelectSyllabusFilterNotifier {
  @override
  SelectSyllabusFilters? build() {
    return null;
  }

  void initialize() {
    final latestYear =
        ref.read(syllabusFiltersNotifierProvider)?.year.values.first;
    state = SelectSyllabusFilters(year: latestYear!);
  }

  void setYear({required String year}) {
    state = SelectSyllabusFilters(year: year);
  }

  void changeWord({
    required String word,
  }) {
    state = state?.copyWith(
      word: word,
    );
  }

  // ignore: use_setters_to_change_properties
  void change({required SelectSyllabusFilters filter}) {
    state = filter;
  }
}
