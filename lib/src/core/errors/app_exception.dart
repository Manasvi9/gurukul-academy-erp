sealed class AppException implements Exception {
  const AppException(this.message, {this.cause, this.stackTrace});

  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  @override
  String toString() => message;
}

final class ConfigurationException extends AppException {
  const ConfigurationException(super.message, {super.cause, super.stackTrace});
}

final class NetworkException extends AppException {
  const NetworkException(super.message, {super.cause, super.stackTrace});
}

final class RepositoryException extends AppException {
  const RepositoryException(super.message, {super.cause, super.stackTrace});
}

final class ValidationException extends AppException {
  const ValidationException(super.message, {super.cause, super.stackTrace});
}
