import '../../../../core/models/result.dart';
import '../repositories/auth_repository.dart';

final class LogoutUseCase {
  const LogoutUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call() {
    return _repository.logout();
  }
}
