import 'package:aitapp/models/map_shape.dart';

class BuildingInfo {
  BuildingInfo({
    required this.id,
    required this.name,
    this.classrooms,
    this.mapShape,
  });
  final int id;
  final String name;
  final Map<String, List<String>>? classrooms;
  MapShape? mapShape;
}
