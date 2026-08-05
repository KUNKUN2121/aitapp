// 授業
import 'package:aitapp/application/state/class_timetable/class_timetable.dart';
import 'package:aitapp/domain/types/class.dart';
import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/presentation/screens/syllabus_search.dart';
import 'package:aitapp/utils/extended_string.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

class ClassGridContainer extends ConsumerWidget {
  const ClassGridContainer({
    required this.dayOfWeek,
    required this.classPeriod,
    this.clas,
    super.key,
  });

  final DayOfWeek dayOfWeek;
  final int classPeriod;
  final Class? clas;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onTap: () {
        final subjectCode = clas?.subjectCode;
        final classCode = clas?.classCode;
        final hasCode = subjectCode != null && classCode != null;
        // 授業コードがあれば一意に特定できるためコードのみで検索する
        // (集中講義・通年で曜日/時限が一致せず0件になるのを防ぐ)。
        // 空きコマのときは曜日+時限でその枠の授業一覧を表示する。
        final word = hasCode ? '$subjectCode $classCode' : null;
        final selectYear =
            ref.read(classTimeTableNotifierProvider.notifier).selectYear;
        Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (ctx) => SyllabusSearchScreen(
              initialWord: word,
              initialWeek: hasCode ? null : dayOfWeek,
              initialHour: hasCode ? null : classPeriod,
              initialYear: selectYear,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(6)),
          color: clas != null
              ? Theme.of(context).colorScheme.secondaryContainer
              : Theme.of(context).colorScheme.primaryContainer,
        ),
        width: double.infinity,
        margin: const EdgeInsets.all(2),
        height: 82,
        padding: const EdgeInsets.all(4),
        alignment: Alignment.topCenter,
        child: clas != null
            ? Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    clas!.title,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Container(
                    padding: const EdgeInsets.all(2),
                    alignment: Alignment.center,
                    width: double.infinity - 5,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                      color: Theme.of(context)
                          .colorScheme
                          .primary
                          .withValues(alpha: 0.6),
                    ),
                    child: Text(
                      clas!.classRoom.alphanumericToHalfLength(),
                      style: TextStyle(
                        fontSize: 10,
                        color:
                            Theme.of(context).colorScheme.onTertiaryContainer,
                      ),
                    ),
                  ),
                ],
              )
            : null,
      ),
    );
  }
}
