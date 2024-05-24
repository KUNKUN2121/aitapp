extension ExtendedString on String {
  //  空白を削除する
  String removeAllWhitespace() {
    // Remove all white space.
    return replaceAll(RegExp(r'\s+'), '');
  }

  // 全角を半角にする
  String alphanumericToHalfLength() {
    return replaceAllMapped(RegExp(r'[^\u0020-\u007E\uFF61-\uFF9F]+'), (match) {
      return match
          .group(0)!
          .codeUnits
          .map((codeUnit) {
            if (codeUnit >= 0xFF01 && codeUnit <= 0xFF5E) {
              // 全角英数字の範囲
              return codeUnit - 0xFEE0;
            } else {
              return codeUnit;
            }
          })
          .map(String.fromCharCode)
          .join();
    });
  }
}
