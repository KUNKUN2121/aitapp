import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

class MapShape {
  MapShape({
    required String strPath,
    required this.strokeColor,
    required this.strokeWidth,
    required this.isSelectable,
    required this.id,
    this.fillColor,
    required this.isSelect,
  }) : _path = parseSvgPathData(strPath);

  /// transforms a [_path] into [transformedPath] using given [matrix]
  void transform(Matrix4 matrix) =>
      transformedPath = _path.transform(matrix.storage);

  final Path _path;
  Path? transformedPath;
  final Color strokeColor;
  final Color? fillColor;
  final double strokeWidth;
  final bool isSelectable;
  final int id;
  bool isSelect;
}
