import 'auth_user.dart';

final class AuthSession {
  const AuthSession({
    required this.user,
    required this.accessToken,
    required this.expiresAt,
    this.refreshToken,
  });

  final AuthUser user;
  final String accessToken;
  final String? refreshToken;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
