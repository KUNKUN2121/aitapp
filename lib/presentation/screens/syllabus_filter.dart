import 'package:aitapp/domain/types/day_of_week.dart';
import 'package:aitapp/presentation/screens/syllabus_detail.dart';
import 'package:aitapp/presentation/wighets/search_bar.dart';
import 'package:aitapp/presentation/wighets/syllabus_filtered_list.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class SyllabusFilterScreen extends HookWidget {
  const SyllabusFilterScreen({
    super.key,
    required this.dayOfWeek,
    required this.classPeriod,
    this.teacher,
    this.subjectCode,
    this.classCode,
  });

  final DayOfWeek dayOfWeek;
  final int classPeriod;
  final String? teacher;
  final String? subjectCode;
  final String? classCode;

  @override
  Widget build(BuildContext context) {
    final controller = useTextEditingController();
    final filter = useState('');
    // 初回検索が「複数/0件/エラー」に確定してから検索バー付きリストを表示する。
    // 1件だけのときは詳細へ自動遷移するので検索バーは出さない。
    final showList = useState(false);

    // 教員名はプリセットしない(複数ヒットは一覧表示し、手動で絞り込ませる)。
    useEffect(
      () {
        controller.addListener(() {
          filter.value = controller.text;
        });
        return null;
      },
      [],
    );
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        elevation: 0,
        centerTitle: true,
        title: Text(
          '${dayOfWeek.displayName} $classPeriod限から検索',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Column(
        children: [
          if (showList.value)
            SearchBarWidget(
              controller: controller,
              hintText: '教授名、授業名で検索',
            ),
          SyllabusList(
            classPeriod: classPeriod,
            dayOfWeek: dayOfWeek,
            filterText: showList.value ? filter.value : null,
            subjectCode: subjectCode,
            classCode: classCode,
            teacher: teacher,
            onSingleResult: (single, getSyllabus) {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (ctx) => SyllabusDetail(
                    syllabus: single,
                    getSyllabus: getSyllabus,
                  ),
                ),
              );
            },
            onMultipleResults: () => showList.value = true,
          ),
        ],
      ),
    );
  }
}
