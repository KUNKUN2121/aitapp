enum Classification {
  required('必修'),
  choice('選択'),
  requiredElective('選必'),
  unknown('不明');

  const Classification(this.displayName);
  final String displayName;
}
