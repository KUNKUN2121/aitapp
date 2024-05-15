enum Semester {
  early('前期', 1),
  late('後期', 2),
  fullYear('通年', 3);

  const Semester(this.displayName, this.num);
  final String displayName;
  final int num;
}
