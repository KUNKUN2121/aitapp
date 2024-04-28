import 'dart:convert';

import 'package:aitapp/models/map_shape.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:xml/xml.dart';

class SVGMap extends HookWidget {
  const SVGMap({super.key});

  @override
  Widget build(BuildContext context) {
    final pointerDownPosition = useRef<Offset?>(null);
    void traverseTree(XmlNode node, List<XmlNode> result) {
      if (node.children.isNotEmpty) {
        for (final child in node.children) {
          traverseTree(child, result);
        }
      } else {
        if (node.nodeType == XmlNodeType.ELEMENT) {
          result.add(node);
        }
      }
    }

    final notifier = useState(Offset.zero);
    final shapes = useState<List<MapShape>?>(null);
    useEffect(
      () {
        rootBundle.load('assets/images/map.svg').then(
          (ByteData data) {
            debugPrint('load: ${data.lengthInBytes}');

            final document =
                XmlDocument.parse(utf8.decode(data.buffer.asUint8List()));
            final strokeRoot = document.findAllElements('svg').first;
            final result = <XmlNode>[];
            traverseTree(strokeRoot, result);

            final loadShapes = <MapShape>[];
            for (final node in result) {
              final data = node.getAttribute('d');
              final strokeWidth = node.getAttribute('stroke-width');
              final strokeColor = node.getAttribute('stroke');
              final fillColor = node.getAttribute('fill');
              if (data != null) {
                loadShapes.add(
                  MapShape(
                    strPath: data,
                    strokeColor: strokeColor != null
                        ? HexColor.from(strokeColor)
                        : const Color.fromARGB(0, 0, 0, 0),
                    fillColor: fillColor != 'none' && fillColor != null
                        ? HexColor.from(fillColor)
                        : const Color.fromARGB(0, 0, 0, 0),
                    strokeWidth: double.parse(strokeWidth ?? '0.0'),
                    isSelectable:
                        node.parentElement!.parentElement!.getAttribute('id') ==
                            'selectable',
                    id: int.parse(node.getAttribute('data-name') ?? '0'),
                  ),
                );
              }
            }
            shapes.value = loadShapes;
          },
        );
        return null;
      },
      [],
    );
    return Listener(
      onPointerDown: (e) {
        pointerDownPosition.value = e.position;
      },
      onPointerUp: (e) {
        if (e.position == pointerDownPosition.value) {
          for (final shape in shapes.value!) {
            final path = shape.transformedPath;
            final selected =
                path!.contains(e.localPosition) && shape.isSelectable;
            if (selected) {
              notifier.value = e.localPosition;
            }
          }
        }

        pointerDownPosition.value = null;
      },
      child: RepaintBoundary(
        child: CustomPaint(
          painter: SVGMapRender(notifier, shapes.value),
          child: const SizedBox.expand(),
        ),
      ),
    );
  }
}

class SVGMapRender extends CustomPainter {
  SVGMapRender(this._notifier, this._shapes) : super(repaint: _notifier);
  final List<MapShape>? _shapes;

  final ValueNotifier<Offset> _notifier;
  final Paint _paint = Paint();
  Size _size = Size.zero;

  @override
  void paint(Canvas canvas, Size size) {
    if (size != _size) {
      _size = size;
      final fs = applyBoxFit(BoxFit.contain, const Size(3200, 1600), size);
      final r = Alignment.center.inscribe(fs.destination, Offset.zero & size);
      final matrix = Matrix4.translationValues(r.left, r.top, 0)
        ..scale(fs.destination.width / fs.source.width);
      if (_shapes != null) {
        for (final shape in _shapes!) {
          shape.transform(matrix);
        }
      }
      // print('new size: $_size');
    }

    canvas
      ..clipRect(Offset.zero & size)
      ..drawColor(const Color.fromARGB(255, 243, 243, 243), BlendMode.src);
    MapShape? selectedMapShape;
    if (_shapes != null) {
      for (final shape in _shapes!) {
        final path = shape.transformedPath;
        final selected = path!.contains(_notifier.value) && shape.isSelectable;
        if (shape.fillColor != null) {
          _paint
            ..color = shape.fillColor!
            ..style = PaintingStyle.fill;
          canvas.drawPath(path, _paint);
          selectedMapShape ??= selected ? shape : null;
        }

        _paint
          ..color = shape.strokeColor
          ..strokeWidth = shape.strokeWidth / 10
          ..style = PaintingStyle.stroke;
        canvas.drawPath(path, _paint);
      }
    }
    if (selectedMapShape != null) {
      _paint
        ..color = selectedMapShape.strokeColor
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;
      print(selectedMapShape.id);
      canvas.drawPath(selectedMapShape.transformedPath!, _paint);
      _paint.maskFilter = null;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

extension HexColor on Color {
  static Color from(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) {
      buffer
        ..write('FF')
        ..write(hexString.replaceAll('#', ''));
    } else if (hexString.length == 4 || hexString.length == 5) {
      buffer.write('FF');
      for (var i = hexString.length == 4 ? 1 : 2; i < hexString.length; i++) {
        buffer
          ..write(hexString[i])
          ..write(hexString[i]);
      }
    } else {
      throw ArgumentError('Invalid hexString: $hexString');
    }
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}
