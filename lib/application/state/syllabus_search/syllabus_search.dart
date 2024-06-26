import 'package:aitapp/application/state/select_syllabus_filter/select_syllabus_filter.dart';
import 'package:aitapp/application/usecases/syllabus_search_usecase.dart';
import 'package:aitapp/domain/types/class_syllabus.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'syllabus_search.g.dart';

@riverpod
class SyllabusSearchNotifier extends _$SyllabusSearchNotifier {
  @override
  AsyncValue<List<ClassSyllabus>> build() {
    return const AsyncValue.data([]);
  }

  Future<void> fetchData(
    SyllabusSearchUseCase useCase,
  ) async {
    state = const AsyncValue.loading();
    final selectFilter = ref.read(selectSyllabusFilterNotifierProvider);
    try {
      final result = await useCase.load(selectFilter!);
      state = AsyncValue.data(result);
    } on Exception catch (err, stack) {
      state = AsyncValue.error(err, stack);
    }
  }

  void clear() {
    state = const AsyncValue.data([]);
  }
}
