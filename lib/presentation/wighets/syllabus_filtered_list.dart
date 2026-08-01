import 'dart:io';

import 'package:aitapp/application/state/class_timetable/class_timetable.dart';
import 'package:aitapp/domain/features/get_syllabus.dart';
import 'package:aitapp/domain/types/class_syllabus.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/domain/types/exception.dart';
import 'package:aitapp/domain/types/select_syllabus_filters.dart';
import 'package:aitapp/presentation/wighets/loading/syllabus_loading.dart';
import 'package:aitapp/presentation/wighets/syllabus_item.dart';
import 'package:async/async.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

/// 時間割の担当教員名とシラバスの教員名がおおよそ一致するか。
/// 空白を除去し、どちらかがもう一方を含めば一致とみなす(姓のみ表記に対応)。
bool _teacherMatches(String syllabusTeacher, String timetableTeacher) {
  String norm(String s) => s.replaceAll(RegExp(r'\s+'), '');
  final a = norm(syllabusTeacher);
  final b = norm(timetableTeacher);
  if (a.isEmpty || b.isEmpty) {
    return false;
  }
  return a.contains(b) || b.contains(a);
}

class SyllabusList extends HookConsumerWidget {
  const SyllabusList({
    super.key,
    this.dayOfWeek,
    this.classPeriod,
    this.filterText,
    this.subjectCode,
    this.classCode,
    this.teacher,
    this.onSingleResult,
    this.onMultipleResults,
  });
  final DayOfWeek? dayOfWeek;
  final int? classPeriod;
  final String? filterText;
  final String? subjectCode;
  final String? classCode;
  // 時間割上の担当教員名(複数ヒット時の絞り込み用)
  final String? teacher;

  // 初回検索で結果が1件だけのとき呼ばれる。呼び出し側で詳細画面へ遷移する。
  final void Function(ClassSyllabus single, GetSyllabus getSyllabus)?
      onSingleResult;

  // 初回検索の結果が1件でない(0件/複数/エラー)ときに呼ばれる。
  // 呼び出し側で検索バー付きのリスト表示に切り替える。
  final void Function()? onMultipleResults;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.watch(classTimeTableNotifierProvider.notifier);
    final getSyllabus = useMemoized(GetSyllabus.new);
    final operation = useRef<CancelableOperation<void>?>(null);
    final syllabusList = useState<List<ClassSyllabus>?>(null);
    // 1件だけで詳細へ自動遷移する間はローディングを表示し続ける
    final autoOpening = useState<bool>(false);
    final content = useState<Widget>(
      const Expanded(
        child: SyllabusLoadingWidget(),
      ),
    );

    // 指定条件で検索する。0件(NotFound)は空リストとして扱う。
    Future<List<ClassSyllabus>> search(SelectSyllabusFilters filters) async {
      try {
        return await getSyllabus.getSyllabusList(
          selectSyllabusFilters: filters,
        );
      } on NotFoundException {
        return <ClassSyllabus>[];
      }
    }

    // 検索バー付きリスト表示への切り替えを次フレームで呼び出し側に通知する。
    void notifyMultiple() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        onMultipleResults?.call();
      });
    }

    Future<void> load() async {
      try {
        await getSyllabus.create();
        final selectYear = notifier.selectYear;
        final yearKey = getSyllabus.filters.year.keys.firstWhere(
          (k) => k.startsWith('$selectYear'),
          orElse: () => '',
        );
        final yearValue = getSyllabus.filters.year[yearKey] ?? '';

        var list = <ClassSyllabus>[];
        if (subjectCode != null && classCode != null) {
          final word = '$subjectCode $classCode';
          // 1. コード + 曜日 + 時限 (最も厳密)
          list = await search(
            SelectSyllabusFilters(
              year: yearValue,
              word: word,
              week: dayOfWeek,
              hour: classPeriod,
            ),
          );
          // 同一コードで教員だけ違う複数ヒット時は担当教員名で1件に絞る。
          // 絞れない場合は全件のまま一覧表示する。
          if (list.length > 1 && teacher != null && teacher!.isNotEmpty) {
            final narrowed = list
                .where((s) => _teacherMatches(s.teacher, teacher!))
                .toList();
            if (narrowed.length == 1) {
              list = narrowed;
            }
          }
          // 2. 0件 → コードのみで再検索 (集中講義・通年・複数時限の保険)
          if (list.isEmpty) {
            list = await search(
              SelectSyllabusFilters(
                year: yearValue,
                word: word,
              ),
            );
          }
        }
        // 3. まだ0件 (コード無し含む) → 従来の曜日+時限検索にフォールバック
        if (list.isEmpty) {
          list = await search(
            SelectSyllabusFilters(
              week: dayOfWeek,
              hour: classPeriod,
              year: yearValue,
              semester: notifier.selectSemester,
            ),
          );
        }

        syllabusList.value = list;
        if (list.length == 1 && onSingleResult != null) {
          autoOpening.value = true;
          WidgetsBinding.instance.addPostFrameCallback((_) {
            onSingleResult!(list.first, getSyllabus);
          });
        } else {
          notifyMultiple();
        }
      } on SocketException {
        content.value = const Center(
          child: Text('インターネットに接続できません'),
        );
        notifyMultiple();
      } on Exception catch (err) {
        content.value = Center(
          child: Text(err.toString()),
        );
        notifyMultiple();
      }
    }

    useEffect(
      () {
        operation.value = CancelableOperation.fromFuture(
          load(),
        );

        return () {
          operation.value!.cancel();
        };
      },
      [],
    );

    // 1件だけで自動遷移する間はローディングのまま
    if (autoOpening.value) {
      return content.value;
    }

    if (syllabusList.value != null) {
      late List<ClassSyllabus> result;
      if (filterText != null) {
        result = syllabusList.value!
            .where(
              (syllabus) =>
                  syllabus.teacher.toLowerCase().contains(filterText!) ||
                  syllabus.subject.toLowerCase().contains(filterText!),
            )
            .toList();
      } else {
        result = syllabusList.value!;
      }
      if (result.isEmpty) {
        return const Expanded(
          child: Center(
            child: Text('シラバスが見つかりませんでした'),
          ),
        );
      }
      return Expanded(
        child: ListView.builder(
          itemCount: result.length,
          itemBuilder: (c, i) => SyllabusItem(
            syllabus: result[i],
            getSyllabus: getSyllabus,
          ),
        ),
      );
    }
    return content.value;
  }
}
