enum DayOfWeek {
  sunday('日', 7),
  monday('月', 1),
  tuesday('火', 2),
  wednesday('水', 3),
  thurstay('木', 4),
  friday('金', 5),
  saturday('土', 6),
  offHours('時間割外・集中講義', 0);

  const DayOfWeek(this.displayName, this.num);
  final String displayName;
  final int num;
}
