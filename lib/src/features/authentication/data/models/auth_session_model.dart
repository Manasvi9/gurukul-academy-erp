import '../../domain/entities/auth_session.dart';
import 'auth_user_model.dart';

final class AuthSessionModel extends AuthSession {
  const AuthSessionModel({
    required AuthUserModel super.user,
    required super.accessToken,
    required super.expiresAt,
    super.refreshToken,
  });

  factory AuthSessionModel.fromJson(Map<String, Object?> json) {
    return AuthSessionModel(
      user: AuthUserModel.fromJson(json['user'] as Map<String, Object?>),
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String?,
      expiresAt: DateTime.parse(json['expires_at'] as String),
    );
  }

  factory AuthSessionModel.fromEntity(AuthSession session) {
    return AuthSessionModel(
      user: AuthUserModel.fromEntity(session.user),
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: session.expiresAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'user': (user as AuthUserModel).toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}
