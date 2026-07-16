import '../../../../core/models/result.dart';
import '../entities/auth_session.dart';
import '../entities/auth_user.dart';
import '../entities/login_credentials.dart';

abstract interface class AuthRepository {
  Future<Result<AuthSession>> login(LoginCredentials credentials);

  Future<Result<AuthSession?>> restoreSession();

  Future<Result<void>> logout();

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<Result<void>> sendStaffPasswordResetEmail(String email);

  Stream<AuthUser?> watchAuthUser();
}
