import 'package:flutter_test/flutter_test.dart';
import 'package:gurukul_academy_erp/src/core/validation/validators.dart';

void main() {
  group('Validators', () {
    test('requiredText rejects blank text', () {
      expect(
        Validators.requiredText('   ', fieldName: 'Name'),
        'Name is required.',
      );
    });

    test('email rejects invalid email shape', () {
      expect(
        Validators.email('principal'),
        'Enter a valid email address.',
      );
    });

    test('password requires at least eight characters', () {
      expect(
        Validators.password('1234567'),
        'Password must be at least 8 characters.',
      );
    });

    test('mobile number requires Indian mobile shape', () {
      expect(
        Validators.mobileNumber('12345'),
        'Enter a valid 10 digit mobile number.',
      );
      expect(Validators.mobileNumber('9876543210'), isNull);
    });

    test('sr number only requires a non-empty value', () {
      expect(Validators.srNumber('SR-125'), isNull);
      expect(Validators.srNumber(' '), 'SR number is required.');
    });
  });
}
