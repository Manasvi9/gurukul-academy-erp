import '../../domain/entities/auth_role.dart';
import '../../domain/entities/auth_user.dart';

final class AuthUserModel extends AuthUser {
  const AuthUserModel({
    required super.id,
    required super.role,
    required super.displayName,
    required super.mustChangePassword,
  });

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

  Map<String, Object?> toJson() {
    return {
      'id': id,
      'role': role.value,
      'display_name': displayName,
      'must_change_password': mustChangePassword,
    };
  }
}
