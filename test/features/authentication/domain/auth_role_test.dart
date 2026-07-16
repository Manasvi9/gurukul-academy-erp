import 'package:flutter_test/flutter_test.dart';
import 'package:gurukul_academy_erp/src/features/authentication/domain/entities/auth_role.dart';

void main() {
  group('AuthRole', () {
    test('staff roles use Supabase Auth', () {
      expect(AuthRole.systemAdmin.usesSupabaseAuth, isTrue);
      expect(AuthRole.director.usesSupabaseAuth, isTrue);
      expect(AuthRole.principal.usesSupabaseAuth, isTrue);
      expect(AuthRole.teacher.usesSupabaseAuth, isTrue);
    });

    test('parent and student use custom authentication', () {
      expect(AuthRole.parent.usesSupabaseAuth, isFalse);
      expect(AuthRole.student.usesSupabaseAuth, isFalse);
    });

    test('parses role values', () {
      expect(AuthRole.fromValue('student'), AuthRole.student);
    });
  });
}
