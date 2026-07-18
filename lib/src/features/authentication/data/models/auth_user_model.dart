import '../../domain/entities/auth_role.dart';
import '../../domain/entities/auth_user.dart';

/// Serializable data representation of an authenticated user.
///
/// This deliberately implements the domain contract instead of extending it:
/// domain entities are final value types and must not be used as base classes.
final class AuthUserModel {
  const AuthUserModel({
    required this.id,
    required this.role,
    required this.displayName,
    required this.mustChangePassword,
  });

  final String id;

  final AuthRole role;

  final String displayName;

  final bool mustChangePassword;

  factory AuthUserModel.fromJson(Map<String, Object?> json) {
    return AuthUserModel(
      id: json['id'] as String,
      role: AuthRole.fromValue(json['role'] as String),
      displayName: json['display_name'] as String,
      mustChangePassword: json['must_change_password'] as bool,
    );
  }

  factory AuthUserModel.fromEntity(AuthUser user) {
    return AuthUserModel(
      id: user.id,
      role: user.role,
      displayName: user.displayName,
      mustChangePassword: user.mustChangePassword,
    );
  }

  AuthUser toEntity() {
    return AuthUser(
      id: id,
      role: role,
      displayName: displayName,
      mustChangePassword: mustChangePassword,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'role': role.value,
      'display_name': displayName,
      'must_change_password': mustChangePassword,
    };
  }
}
