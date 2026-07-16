import 'package:flutter_test/flutter_test.dart';
import 'package:gurukul_academy_erp/src/core/errors/app_failure.dart';
import 'package:gurukul_academy_erp/src/core/models/result.dart';

void main() {
  group('Result', () {
    test('maps success value', () {
      const result = Success<int>(42);

      final value = result.when(
        success: (value) => value,
        failure: (_) => 0,
      );

      expect(value, 42);
    });

    test('maps failure value', () {
      const result = Failure<int>(ValidationFailure('Invalid input'));

      final value = result.when(
        success: (_) => 'success',
        failure: (failure) => failure.message,
      );

      expect(value, 'Invalid input');
    });
  });
}
