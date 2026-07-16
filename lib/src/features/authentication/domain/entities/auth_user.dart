import 'auth_role.dart';

final class AuthUser {
  const AuthUser({
    required this.id,
    required this.role,
    required this.displayName,
    required this.mustChangePassword,
  });

  final String id;
  final AuthRole role;
  final String displayName;
  final bool mustChangePassword;
}
