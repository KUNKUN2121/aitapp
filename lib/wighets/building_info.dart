class BuildingInfo {
  const BuildingInfo({
    required this.id,
    required this.name,
    required this.classrooms,
  });

  final int id;
  final String name;
  final Map<String, List<String>> classrooms;
}
