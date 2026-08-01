// 授業アンケート一覧の subjectDispCode から取り出す授業コード・クラスコード。
//
// value 例 "K1018000_X1" を 授業コード "K1018000" と クラスコード "X1" に分解する。
// シラバス検索の freeWord に "授業コード クラスコード"(スペース区切り)として渡すと
// 年度指定と合わせて一意にシラバスを特定できる。
class DispCode {
  const DispCode({
    required this.subjectCode,
    required this.classCode,
  });

  /// "K1018000_X1" 形式の value をパースする。分解できない場合は null。
  static DispCode? tryParse(String value) {
    final index = value.indexOf('_');
    if (index <= 0 || index >= value.length - 1) {
      return null;
    }
    return DispCode(
      subjectCode: value.substring(0, index),
      classCode: value.substring(index + 1),
    );
  }

  // 授業コード 例 K1018000
  final String subjectCode;
  // クラスコード 例 X1
  final String classCode;

  /// シラバス検索の freeWord に渡す文字列。
  String get searchWord => '$subjectCode $classCode';

  @override
  bool operator ==(Object other) =>
      other is DispCode &&
      other.subjectCode == subjectCode &&
      other.classCode == classCode;

  @override
  int get hashCode => Object.hash(subjectCode, classCode);
}
