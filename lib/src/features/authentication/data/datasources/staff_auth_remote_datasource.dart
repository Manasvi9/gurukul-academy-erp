import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/auth_role.dart';
import '../../domain/entities/login_credentials.dart';
import '../models/auth_session_model.dart';
import '../models/auth_user_model.dart';

abstract interface class StaffAuthRemoteDataSource {
  Future<AuthSessionModel> login(StaffLoginCredentials credentials);

  Future<AuthSessionModel?> restoreSession();

  Future<void> logout();

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<void> sendPasswordResetEmail(String email);

  Stream<AuthUserModel?> watchUser();
}

final class SupabaseStaffAuthRemoteDataSource
    implements StaffAuthRemoteDataSource {
  SupabaseStaffAuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<AuthSessionModel> login(StaffLoginCredentials credentials) async {
    final response = await _client.auth.signInWithPassword(
      email: credentials.email.trim(),
      password: credentials.password,
    );

    final session = response.session;
    final user = response.user;
    if (session == null || user == null) {
      throw AuthException('Unable to create staff session.');
    }

    final appUser = await _loadStaffProfile(user.id);
    _ensureSelectedRole(appUser.role, credentials.role);
    return _mapStaffSession(session, appUser);
  }

  @override
  Future<AuthSessionModel?> restoreSession() async {
    final session = _client.auth.currentSession;
    final user = _client.auth.currentUser;
    if (session == null || user == null) {
      return null;
    }

    final appUser = await _loadStaffProfile(user.id);
    return _mapStaffSession(session, appUser);
  }

  @override
  Future<void> logout() {
    return _client.auth.signOut();
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) {
    return _changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  Future<void> _changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final user = _client.auth.currentUser;
    final email = user?.email;
    if (user == null || email == null) {
      throw AuthException('No staff session found.');
    }

    await _client.auth.signInWithPassword(
      email: email,
      password: currentPassword,
    );
    await _client.auth.updateUser(
      UserAttributes(password: newPassword),
    );
    await _client
        .from('staff_auth_profiles')
        .update({'must_change_password': false}).eq('id', user.id);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) {
    return _client.auth.resetPasswordForEmail(email.trim());
  }

  @override
  Stream<AuthUserModel?> watchUser() async* {
    await for (final event in _client.auth.onAuthStateChange) {
      final user = event.session?.user;
      if (user == null) {
        yield null;
        continue;
      }
      yield await _loadStaffProfile(user.id);
    }
  }

  Future<AuthUserModel> _loadStaffProfile(String userId) async {
    final response = await _client
        .from('staff_auth_profiles')
        .select('id, role, display_name, must_change_password')
        .eq('id', userId)
        .single();

    return AuthUserModel.fromJson(response);
  }

  void _ensureSelectedRole(AuthRole actualRole, AuthRole selectedRole) {
    if (actualRole != selectedRole) {
      throw AuthException(
        'This account is registered as ${actualRole.label}. Please choose the correct login type.',
      );
    }
  }

  AuthSessionModel _mapStaffSession(Session session, AuthUserModel user) {
    final expiresAt = session.expiresAt;
    if (expiresAt == null) {
      throw AuthException('Staff session expiry is missing.');
    }

    return AuthSessionModel(
      user: user,
      accessToken: session.accessToken,
      refreshToken: session.refreshToken,
      expiresAt: DateTime.fromMillisecondsSinceEpoch(
        expiresAt * 1000,
      ),
    );
  }
}
