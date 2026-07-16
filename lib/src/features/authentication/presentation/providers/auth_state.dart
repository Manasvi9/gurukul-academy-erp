import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';

enum AuthStatus {
  initial,
  authenticating,
  authenticated,
  unauthenticated,
  failure;
}

final class AuthState {
  const AuthState({
    required this.status,
    this.session,
    this.message,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        session = null,
        message = null;

  final AuthStatus status;
  final AuthSession? session;
  final String? message;

  AuthUser? get user => session?.user;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  bool get mustChangePassword => user?.mustChangePassword ?? false;

  AuthState markPasswordChanged() {
    final currentSession = session;
    final currentUser = user;
    if (currentSession == null || currentUser == null) {
      return this;
    }

    return AuthState(
      status: status,
      session: AuthSession(
        user: AuthUser(
          id: currentUser.id,
          role: currentUser.role,
          displayName: currentUser.displayName,
          mustChangePassword: false,
        ),
        accessToken: currentSession.accessToken,
        refreshToken: currentSession.refreshToken,
        expiresAt: currentSession.expiresAt,
      ),
      message: message,
    );
  }

  AuthState copyWith({
    AuthStatus? status,
    AuthSession? session,
    String? message,
    bool clearMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      session: session ?? this.session,
      message: clearMessage ? null : message ?? this.message,
    );
  }
}
