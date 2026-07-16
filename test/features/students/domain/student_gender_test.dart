import 'package:flutter_test/flutter_test.dart';
import 'package:gurukul_academy_erp/src/features/students/domain/entities/student_gender.dart';

void main() {
  group('StudentGender', () {
    test('parses supported values', () {
      expect(StudentGender.fromValue('male'), StudentGender.male);
      expect(StudentGender.fromValue('female'), StudentGender.female);
      expect(StudentGender.fromValue('other'), StudentGender.other);
    });

    test('rejects unsupported values', () {
      expect(() => StudentGender.fromValue('unknown'), throwsFormatException);
    });
  });
}
