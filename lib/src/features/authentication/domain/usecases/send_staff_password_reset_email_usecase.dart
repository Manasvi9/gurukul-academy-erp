import '../../../../core/models/result.dart';
import '../repositories/auth_repository.dart';

final class SendStaffPasswordResetEmailUseCase {
  const SendStaffPasswordResetEmailUseCase(this._repository);

  final AuthRepository _repository;

  Future<Result<void>> call(String email) {
    return _repository.sendStaffPasswordResetEmail(email);
  }
}
