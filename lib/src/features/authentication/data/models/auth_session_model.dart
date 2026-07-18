import '../../domain/entities/auth_session.dart';
import 'auth_user_model.dart';

/// Serializable data representation of an authenticated session.
///
/// It implements the final domain contract rather than inheriting from it.
final class AuthSessionModel {
  const AuthSessionModel({
    required this.user,
    required this.accessToken,
    required this.expiresAt,
    this.refreshToken,
  });

  final AuthUserModel user;

  final String accessToken;

  final String? refreshToken;

  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);

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

  AuthSession toEntity() {
    return AuthSession(
      user: user.toEntity(),
      accessToken: accessToken,
      refreshToken: refreshToken,
      expiresAt: expiresAt,
    );
  }

  Map<String, Object?> toJson() {
    return {
      'user': user.toJson(),
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'expires_at': expiresAt.toIso8601String(),
    };
  }
}
