import 'dart:async';

import '../../../../core/models/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/custom_auth_remote_datasource.dart';
import '../datasources/staff_auth_remote_datasource.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';

final class AuthRepositoryImpl extends BaseRepository
    implements AuthRepository {
  AuthRepositoryImpl({
    required StaffAuthRemoteDataSource staffRemoteDataSource,
    required CustomAuthRemoteDataSource customRemoteDataSource,
    required AuthLocalDataSource localDataSource,
  })  : _staffRemoteDataSource = staffRemoteDataSource,
        _customRemoteDataSource = customRemoteDataSource,
        _localDataSource = localDataSource;

  final StaffAuthRemoteDataSource _staffRemoteDataSource;
  final CustomAuthRemoteDataSource _customRemoteDataSource;
  final AuthLocalDataSource _localDataSource;
  final _customUserController = StreamController<AuthUser?>.broadcast();

  AuthSessionModel? _currentCustomSession;

  @override
  Future<Result<AuthSession>> login(LoginCredentials credentials) async {
    return guard(() async {
      if (credentials.role.usesSupabaseAuth) {
        final staffCredentials = credentials as StaffLoginCredentials;
        await _localDataSource.clearCustomSession();
        _currentCustomSession = null;
        _customUserController.add(null);
        return (await _staffRemoteDataSource.login(staffCredentials))
            .toEntity();
      }

      final session = await _customRemoteDataSource.login(credentials);
      _currentCustomSession = session;
      await _localDataSource.saveCustomSession(session);
      _customUserController.add(session.user.toEntity());
      return session.toEntity();
    });
  }

  @override
  Future<Result<AuthSession?>> restoreSession() async {
    return guard(() async {
      final staffSession = await _staffRemoteDataSource.restoreSession();
      if (staffSession != null) {
        return staffSession.toEntity();
      }

      final customSession = await _localDataSource.readCustomSession();
      if (customSession == null) {
        return null;
      }

      if (!customSession.isExpired) {
        _currentCustomSession = customSession;
        _customUserController.add(customSession.user.toEntity());
        return customSession.toEntity();
      }

      final refreshToken = customSession.refreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        await _localDataSource.clearCustomSession();
        return null;
      }

      final refreshedSession = await _customRemoteDataSource.refresh(
        refreshToken,
      );
      _currentCustomSession = refreshedSession;
      await _localDataSource.saveCustomSession(refreshedSession);
      _customUserController.add(refreshedSession.user.toEntity());
      return refreshedSession.toEntity();
    });
  }

  @override
  Future<Result<void>> logout() async {
    return guard(() async {
      final refreshToken = _currentCustomSession?.refreshToken;
      if (refreshToken != null && refreshToken.isNotEmpty) {
        await _customRemoteDataSource.logout(refreshToken);
      }
      await _localDataSource.clearCustomSession();
      _currentCustomSession = null;
      _customUserController.add(null);
      await _staffRemoteDataSource.logout();
    });
  }

  @override
  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    return guard(() async {
      final customSession = _currentCustomSession;
      if (customSession != null) {
        await _customRemoteDataSource.changePassword(
          accessToken: customSession.accessToken,
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
        final updatedSession = AuthSessionModel(
          user: AuthUserModel(
            id: customSession.user.id,
            role: customSession.user.role,
            displayName: customSession.user.displayName,
            mustChangePassword: false,
          ),
          accessToken: customSession.accessToken,
          refreshToken: customSession.refreshToken,
          expiresAt: customSession.expiresAt,
        );
        _currentCustomSession = updatedSession;
        await _localDataSource.saveCustomSession(updatedSession);
        _customUserController.add(updatedSession.user.toEntity());
        return;
      }

      await _staffRemoteDataSource.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );
    });
  }

  @override
  Future<Result<void>> sendStaffPasswordResetEmail(String email) {
    return guard(() => _staffRemoteDataSource.sendPasswordResetEmail(email));
  }

  @override
  Stream<AuthUser?> watchAuthUser() {
    return StreamGroup.merge([
      _staffRemoteDataSource.watchUser().map((user) => user?.toEntity()),
      _customUserController.stream,
    ]);
  }
}

final class StreamGroup {
  const StreamGroup._();

  static Stream<T> merge<T>(Iterable<Stream<T>> streams) {
    // The controller remains open while consumers are subscribed and is owned
    // by the returned stream's lifecycle.
    // ignore: close_sinks
    final controller = StreamController<T>.broadcast();
    final subscriptions = <StreamSubscription<T>>[];

    controller.onListen = () {
      for (final stream in streams) {
        subscriptions.add(stream.listen(controller.add));
      }
    };
    controller.onCancel = () async {
      for (final subscription in subscriptions) {
        await subscription.cancel();
      }
      subscriptions.clear();
    };

    return controller.stream;
  }
}
