import 'package:aitapp/domain/features/syllabus_parse.dart';
import 'package:aitapp/domain/types/class_syllabus.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/syllabus_filter.dart';
import 'package:aitapp/infrastructure/restaccess/access_syllabus.dart';

class GetSyllabus {
  late String jSessionId;
  late SyllabusFilters filters;
  final parse = SyllabusParse();
  Future<void> create() async {
    final res = await getSyllabusSession();
    jSessionId = parse.cookie(res.headers);
    filters = parse.filters(res.body);
  }

  Future<SyllabusFilters> getRefreshFilters({required String year}) async {
    final body =
        await refreshFiltersSession(year: year, jSessionId: jSessionId);
    final filters = parse.filters(body);
    return filters;
  }

  Future<List<ClassSyllabus>> getSyllabusList({
    DayOfWeek? dayOfWeek,
    int? classPeriod,
    String? searchWord,
    String? altWeek,
    String? altPeriod,
    String? campus,
    String? semester,
    String? folder,
    required String year,
  }) async {
    final body = await getSyllabusListBody(
      campus: campus,
      semester: semester,
      week: dayOfWeek?.num,
      hour: classPeriod,
      year: year,
      jSessionId: jSessionId,
      searchWord: searchWord,
      altWeek: altWeek,
      altPeriod: altPeriod,
      folder: folder,
    );
    return parse.searchList(body);
  }

  Future<ClassSyllabusDetail> getSyllabusDetail(ClassSyllabus syllabus) async {
    final body = await getSyllabus(syllabus.url, jSessionId);
    return parse.detail(body);
  }
}
