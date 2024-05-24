import 'package:aitapp/domain/types/map_shape.dart';

// 建物情報
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
