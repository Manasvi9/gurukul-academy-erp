import '../errors/app_exception.dart';
import '../errors/app_failure.dart';
import '../models/result.dart';

abstract base class BaseRepository {
  const BaseRepository();

  Future<Result<T>> guard<T>(Future<T> Function() operation) async {
    try {
      final value = await operation();
      return Success(value);
    } on AppException catch (error) {
      return Failure(_mapException(error));
    } on Object catch (error) {
      return Failure(UnknownFailure(error.toString()));
    }
  }

  AppFailure _mapException(AppException exception) {
    return switch (exception) {
      ConfigurationException(:final message) => ConfigurationFailure(message),
      NetworkException(:final message) => NetworkFailure(message),
      RepositoryException(:final message) => UnknownFailure(message),
      ValidationException(:final message) => ValidationFailure(message),
    };
  }
}
