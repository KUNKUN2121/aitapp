import 'package:aitapp/domain/types/classification.dart';
import 'package:aitapp/domain/types/teacher.dart';

// 授業シラバス詳細
class ClassSyllabusDetail {
  ClassSyllabusDetail(
    this.unitsNumber,
    this.classification,
    this.teachers,
    this.semester,
    this.content,
    this.subject,
    this.classPeriod,
    this.classRoom,
    this.plan,
    this.learningGoal,
    this.features,
    this.records,
    this.teachersMessage,
    this.textBook,
    this.referenceBook,
  );
  final int unitsNumber;
  // 区分
  final Classification classification;
  // 教員名
  final List<Teacher> teachers;
  //開講時期
  final String semester;
  // 内容
  final List<String> content;
  // 教科
  final String subject;
  //教室
  final String classRoom;
  //曜日時限
  final String classPeriod;
  //計画
  final List<String> plan;
  //学習到達目標
  final String learningGoal;
  //方法と特徴
  final String features;
  //成績評価
  final String records;
  //教員メッセージ
  final String teachersMessage;
  // 教科書
  final String textBook;
  // 参考書
  final String referenceBook;
}
