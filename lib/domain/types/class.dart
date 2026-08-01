// 授業
class Class {
  Class({
    required this.title,
    required this.classRoom,
    required this.teacher,
    this.subjectCode,
    this.classCode,
  });

  final String title;
  final String classRoom;
  final String teacher;
  // 授業コード 例 K1018000 (取得できない場合 null)
  final String? subjectCode;
  // クラスコード 例 X1 (取得できない場合 null)
  final String? classCode;

  Class copyWith({
    String? title,
    String? classRoom,
    String? teacher,
    String? subjectCode,
    String? classCode,
  }) {
    return Class(
      title: title ?? this.title,
      classRoom: classRoom ?? this.classRoom,
      teacher: teacher ?? this.teacher,
      subjectCode: subjectCode ?? this.subjectCode,
      classCode: classCode ?? this.classCode,
    );
  }
}
