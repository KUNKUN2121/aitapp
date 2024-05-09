import 'package:aitapp/models/map_shape.dart';
import 'package:flutter/material.dart';

class SVGMapRender extends CustomPainter {
  SVGMapRender({required this.selectShape, required this.shapes});
  final List<MapShape> shapes;
  final Paint _paint = Paint();
  Size _size = Size.zero;
  final MapShape? selectShape;

  @override
  void paint(Canvas canvas, Size size) {
    if (size != _size) {
      _size = size;
      final fs = applyBoxFit(BoxFit.contain, const Size(3200, 1600), size);
      final r = Alignment.center.inscribe(fs.destination, Offset.zero & size);
      final matrix = Matrix4.translationValues(r.left, r.top, 0)
        ..scale(fs.destination.width / fs.source.width);
      for (final shape in shapes) {
        shape.transform(matrix);
      }
      // print('new size: $_size');
    }

    canvas
      ..clipRect(Offset.zero & size)
      ..drawColor(const Color.fromARGB(255, 243, 243, 243), BlendMode.src);
    for (final shape in shapes) {
      final path = shape.transformedPath;
      if (shape.fillColor != null) {
        _paint
          ..color = shape.fillColor!
          ..style = PaintingStyle.fill;
        canvas.drawPath(path!, _paint);
      }
      if (shape == selectShape) {
        _paint
          ..color = shape.strokeColor
          ..strokeWidth = 0.5
          ..style = PaintingStyle.stroke
          ..maskFilter = null;
      } else {
        _paint
          ..color = shape.strokeColor
          ..strokeWidth = shape.strokeWidth / 10
          ..style = PaintingStyle.stroke;
      }
      canvas.drawPath(path!, _paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}
