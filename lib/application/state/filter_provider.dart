import 'package:aitapp/domain/types/select_filter.dart';
import 'package:aitapp/domain/types/syllabus_filter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectFiltersProvider = StateProvider<SelectFilters?>((ref) => null);

final syllabusFiltersProvider = StateProvider<SyllabusFilters?>((ref) => null);
