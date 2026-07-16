import '../../../../core/models/result.dart';
import '../entities/auth_session.dart';
import '../repositories/auth_repository.dart';

final class RestoreSessionUseCase {
  const RestoreSessionUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession?>> call() {
    return _repository.restoreSession();
  }
}
