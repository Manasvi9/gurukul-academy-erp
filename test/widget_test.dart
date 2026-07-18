import 'package:flutter_test/flutter_test.dart';

import 'package:gurukul_academy_erp/src/features/authentication/data/models/auth_session_model.dart';
import 'package:gurukul_academy_erp/src/features/authentication/data/models/auth_user_model.dart';
import 'package:gurukul_academy_erp/src/features/authentication/domain/entities/auth_role.dart';

void main() {
  test('auth session model serializes and deserializes its data', () {
    final session = AuthSessionModel(
      user: AuthUserModel(
        id: 'staff-1',
        role: AuthRole.teacher,
        displayName: 'Asha Sharma',
        mustChangePassword: true,
      ),
      accessToken: 'access-token',
      refreshToken: 'refresh-token',
      expiresAt: DateTime.utc(2026, 7, 16),
    );

    final restored = AuthSessionModel.fromJson(session.toJson());

    expect(restored.user.id, session.user.id);
    expect(restored.user.role, AuthRole.teacher);
    expect(restored.accessToken, session.accessToken);
    expect(restored.refreshToken, session.refreshToken);
    expect(restored.expiresAt, session.expiresAt);
  });
}
