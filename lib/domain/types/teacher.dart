// 教員
class Teacher {
  Teacher({required this.name, required this.ruby});
  final String name;
  final String ruby;
  String toStr() {
    return '$name $ruby';
  }
}
