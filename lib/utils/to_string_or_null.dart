extension ExtendedInt on int? {
  /// The string without any whitespace.
  String? toStringOrNull() {
    if (this != null) {
      return toString();
    }
    return null;
  }
}
