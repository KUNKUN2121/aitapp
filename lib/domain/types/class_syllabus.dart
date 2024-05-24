import 'package:aitapp/domain/types/classification.dart';

// 授業シラバス
class ClassSyllabus {
  ClassSyllabus(
    this.unitsNumber,
    this.classification,
    this.teacher,
    this.subject,
    this.url,
  );
  final int unitsNumber;
  // 区分
  final Classification classification;
  // 教員名
  final String teacher;
  // 教科
  final String subject;
  // URL
  final String url;
}
