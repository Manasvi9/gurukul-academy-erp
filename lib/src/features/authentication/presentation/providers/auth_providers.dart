import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/bootstrap/app_bootstrap.dart';
import '../../../../core/models/result.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/custom_auth_remote_datasource.dart';
import '../../data/datasources/staff_auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/auth_role.dart';
import '../../domain/entities/login_credentials.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/change_password_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/restore_session_usecase.dart';
import '../../domain/usecases/send_staff_password_reset_email_usecase.dart';
import 'auth_state.dart';

final staffAuthRemoteDataSourceProvider = Provider<StaffAuthRemoteDataSource>((
  ref,
) {
  return SupabaseStaffAuthRemoteDataSource(ref.watch(supabaseClientProvider));
});

final customAuthRemoteDataSourceProvider = Provider<CustomAuthRemoteDataSource>((
  ref,
) {
  return SupabaseFunctionCustomAuthRemoteDataSource(
    ref.watch(supabaseClientProvider),
  );
});

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return const SharedPreferencesAuthLocalDataSource();
});

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    staffRemoteDataSource: ref.watch(staffAuthRemoteDataSourceProvider),
    customRemoteDataSource: ref.watch(customAuthRemoteDataSourceProvider),
    localDataSource: ref.watch(authLocalDataSourceProvider),
  );
});

final loginUseCaseProvider = Provider<LoginUseCase>((ref) {
  return LoginUseCase(ref.watch(authRepositoryProvider));
});

final logoutUseCaseProvider = Provider<LogoutUseCase>((ref) {
  return LogoutUseCase(ref.watch(authRepositoryProvider));
});

final restoreSessionUseCaseProvider = Provider<RestoreSessionUseCase>((ref) {
  return RestoreSessionUseCase(ref.watch(authRepositoryProvider));
});

final changePasswordUseCaseProvider = Provider<ChangePasswordUseCase>((ref) {
  return ChangePasswordUseCase(ref.watch(authRepositoryProvider));
});

final sendStaffPasswordResetEmailUseCaseProvider =
    Provider<SendStaffPasswordResetEmailUseCase>((ref) {
  return SendStaffPasswordResetEmailUseCase(ref.watch(authRepositoryProvider));
});

final authControllerProvider =
    StateNotifierProvider<AuthController, AuthState>((ref) {
  return AuthController(
    loginUseCase: ref.watch(loginUseCaseProvider),
    logoutUseCase: ref.watch(logoutUseCaseProvider),
    restoreSessionUseCase: ref.watch(restoreSessionUseCaseProvider),
    changePasswordUseCase: ref.watch(changePasswordUseCaseProvider),
    sendStaffPasswordResetEmailUseCase:
        ref.watch(sendStaffPasswordResetEmailUseCaseProvider),
  )..restoreSession();
});

final authRouteRefreshProvider = Provider<Listenable>((ref) {
  final notifier = ValueNotifier<AuthState>(ref.read(authControllerProvider));

  ref.listen(authControllerProvider, (_, next) {
    notifier.value = next;
  });

  ref.onDispose(notifier.dispose);
  return notifier;
});

final class AuthController extends StateNotifier<AuthState> {
  AuthController({
    required LoginUseCase loginUseCase,
    required LogoutUseCase logoutUseCase,
    required RestoreSessionUseCase restoreSessionUseCase,
    required ChangePasswordUseCase changePasswordUseCase,
    required SendStaffPasswordResetEmailUseCase
        sendStaffPasswordResetEmailUseCase,
  })  : _loginUseCase = loginUseCase,
        _logoutUseCase = logoutUseCase,
        _restoreSessionUseCase = restoreSessionUseCase,
        _changePasswordUseCase = changePasswordUseCase,
        _sendStaffPasswordResetEmailUseCase =
            sendStaffPasswordResetEmailUseCase,
        super(const AuthState.initial());

  final LoginUseCase _loginUseCase;
  final LogoutUseCase _logoutUseCase;
  final RestoreSessionUseCase _restoreSessionUseCase;
  final ChangePasswordUseCase _changePasswordUseCase;
  final SendStaffPasswordResetEmailUseCase _sendStaffPasswordResetEmailUseCase;

  Future<void> restoreSession() async {
    final result = await _restoreSessionUseCase();
    state = result.when(
      success: (session) {
        if (session == null) {
          return const AuthState(status: AuthStatus.unauthenticated);
        }
        return AuthState(
          status: AuthStatus.authenticated,
          session: session,
        );
      },
      failure: (failure) => AuthState(
        status: AuthStatus.unauthenticated,
        message: failure.message,
      ),
    );
  }

  Future<bool> login(LoginCredentials credentials) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      clearMessage: true,
    );

    final result = await _loginUseCase(credentials);
    return result.when(
      success: (session) {
        state = AuthState(
          status: AuthStatus.authenticated,
          session: session,
        );
        return true;
      },
      failure: (failure) {
        state = AuthState(
          status: AuthStatus.failure,
          message: failure.message,
        );
        return false;
      },
    );
  }

  Future<void> logout() async {
    state = state.copyWith(status: AuthStatus.authenticating);
    final result = await _logoutUseCase();
    state = result.when(
      success: (_) => const AuthState(status: AuthStatus.unauthenticated),
      failure: (failure) => AuthState(
        status: AuthStatus.failure,
        session: state.session,
        message: failure.message,
      ),
    );
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(
      status: AuthStatus.authenticating,
      clearMessage: true,
    );
    final result = await _changePasswordUseCase(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );

    return result.when(
      success: (_) {
        if (state.session == null) {
          state = const AuthState(status: AuthStatus.unauthenticated);
          return false;
        }
        state = state.markPasswordChanged().copyWith(
          status: AuthStatus.authenticated,
        );
        return true;
      },
      failure: (failure) {
        state = state.copyWith(
          status: AuthStatus.failure,
          message: failure.message,
        );
        return false;
      },
    );
  }

  Future<bool> sendStaffPasswordResetEmail(String email) async {
    final result = await _sendStaffPasswordResetEmailUseCase(email);
    return result.when(
      success: (_) => true,
      failure: (failure) {
        state = state.copyWith(message: failure.message);
        return false;
      },
    );
  }

  LoginCredentials buildCredentials({
    required AuthRole role,
    required String identifier,
    required String password,
  }) {
    return switch (role) {
      AuthRole.systemAdmin ||
      AuthRole.director ||
      AuthRole.principal ||
      AuthRole.teacher =>
        StaffLoginCredentials(
          email: identifier,
          role: role,
          password: password,
        ),
      AuthRole.parent => ParentLoginCredentials(
          mobileNumber: identifier,
          password: password,
        ),
      AuthRole.student => StudentLoginCredentials(
          srNumber: identifier,
          password: password,
        ),
    };
  }
}
