/// Exception thrown when authentication fails (e.g., 401 Unauthorized)
class UnauthorizedException implements Exception {
  final String message;

  UnauthorizedException(this.message);

  @override
  String toString() => message;
}
