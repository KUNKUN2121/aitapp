import 'package:aitapp/models/map_shape.dart';
import 'package:aitapp/wighets/building_info.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final buildingProvider = StateProvider<BuildingInfo?>((ref) => null);
final shapeProvider = StateProvider<MapShape?>((ref) => null);
