class NotFoundException implements Exception {
  const NotFoundException(this.message);
  final String message;
  @override
  String toString() => message;
}

class GetDataException implements Exception {
  const GetDataException(this.message);
  final String message;
  @override
  String toString() => message;
}
