import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/login_credentials.dart';
import '../dto/custom_auth_login_request.dart';
import '../models/auth_session_model.dart';

abstract interface class CustomAuthRemoteDataSource {
  Future<AuthSessionModel> login(LoginCredentials credentials);

  Future<AuthSessionModel> refresh(String refreshToken);

  Future<void> logout(String refreshToken);

  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  });
}

final class SupabaseFunctionCustomAuthRemoteDataSource
    implements CustomAuthRemoteDataSource {
  SupabaseFunctionCustomAuthRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<AuthSessionModel> login(LoginCredentials credentials) async {
    final request = switch (credentials) {
      ParentLoginCredentials() => CustomAuthLoginRequest.parent(credentials),
      StudentLoginCredentials() => CustomAuthLoginRequest.student(credentials),
      StaffLoginCredentials() => throw AuthException(
          'Staff users must use Supabase Auth.',
        ),
    };

    final response = await _client.functions.invoke(
      'custom-auth-login',
      body: request.body,
    );

    return _sessionFromResponse(response);
  }

  @override
  Future<AuthSessionModel> refresh(String refreshToken) async {
    final response = await _client.functions.invoke(
      'custom-auth-refresh',
      body: {'refresh_token': refreshToken},
    );

    return _sessionFromResponse(response);
  }

  @override
  Future<void> logout(String refreshToken) async {
    final response = await _client.functions.invoke(
      'custom-auth-logout',
      body: {'refresh_token': refreshToken},
    );
    _ensureSuccess(response);
  }

  @override
  Future<void> changePassword({
    required String accessToken,
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _client.functions.invoke(
      'custom-auth-change-password',
      headers: {'Authorization': 'Bearer $accessToken'},
      body: {
        'current_password': currentPassword,
        'new_password': newPassword,
      },
    );
    _ensureSuccess(response);
  }

  AuthSessionModel _sessionFromResponse(FunctionResponse response) {
    _ensureSuccess(response);
    return AuthSessionModel.fromJson(response.data as Map<String, Object?>);
  }

  void _ensureSuccess(FunctionResponse response) {
    if (response.status >= 200 && response.status < 300) {
      return;
    }

    final data = response.data;
    if (data is Map && data['error'] is String) {
      throw AuthException(data['error'] as String);
    }

    throw AuthException('Authentication request failed.');
  }
}
