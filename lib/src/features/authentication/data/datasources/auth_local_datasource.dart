import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/auth_session_model.dart';

abstract interface class AuthLocalDataSource {
  Future<void> saveCustomSession(AuthSessionModel session);

  Future<AuthSessionModel?> readCustomSession();

  Future<void> clearCustomSession();
}

final class SharedPreferencesAuthLocalDataSource
    implements AuthLocalDataSource {
  const SharedPreferencesAuthLocalDataSource();

  static const _sessionKey = 'auth.custom_session';

  @override
  Future<void> saveCustomSession(AuthSessionModel session) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      _sessionKey,
      jsonEncode(session.toJson()),
    );
  }

  @override
  Future<AuthSessionModel?> readCustomSession() async {
    final preferences = await SharedPreferences.getInstance();
    final rawSession = preferences.getString(_sessionKey);
    if (rawSession == null) {
      return null;
    }

    final decoded = jsonDecode(rawSession) as Map<String, Object?>;
    return AuthSessionModel.fromJson(decoded);
  }

  @override
  Future<void> clearCustomSession() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove(_sessionKey);
  }
}
