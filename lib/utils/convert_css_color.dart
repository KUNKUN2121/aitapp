import 'dart:ui';

class ConvertHexColor {
  Color from(String hexString) {
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
