import 'package:aitapp/domain/features/syllabus_parse.dart';
import 'package:aitapp/domain/types/class_syllabus.dart';
import 'package:aitapp/domain/types/class_syllabus_detail.dart';
import 'package:aitapp/domain/types/select_syllabus_filters.dart';
import 'package:aitapp/domain/types/syllabus_filters.dart';
import 'package:aitapp/infrastructure/restaccess/access_syllabus.dart';
import 'package:flutter/material.dart';

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
    required SelectSyllabusFilters selectSyllabusFilters,
    String? searchWord,
  }) async {
    debugPrint(selectSyllabusFilters.toString());
    final body = await getSyllabusListBody(
      campus: selectSyllabusFilters.campus?.num,
      semester: selectSyllabusFilters.semester?.num,
      week: selectSyllabusFilters.week?.num,
      hour: selectSyllabusFilters.hour,
      year: selectSyllabusFilters.year,
      jSessionId: jSessionId,
      searchWord: selectSyllabusFilters.word,
      folder: selectSyllabusFilters.folder,
    );
    return parse.searchList(body);
  }

  Future<ClassSyllabusDetail> getSyllabusDetail(ClassSyllabus syllabus) async {
    final body = await getSyllabus(syllabus.url, jSessionId);
    return parse.detail(body);
  }
}
