import '../../../../core/models/result.dart';
import '../entities/auth_session.dart';
import '../entities/login_credentials.dart';
import '../repositories/auth_repository.dart';

final class LoginUseCase {
  const LoginUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<AuthSession>> call(LoginCredentials credentials) {
    return _repository.login(credentials);
  }
}
