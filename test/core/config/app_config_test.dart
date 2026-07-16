import 'package:flutter_test/flutter_test.dart';
import 'package:gurukul_academy_erp/src/core/config/app_config.dart';
import 'package:gurukul_academy_erp/src/core/logging/log_level.dart';

void main() {
  group('AppEnvironment', () {
    test('parses production aliases', () {
      expect(AppEnvironment.parse('production'), AppEnvironment.production);
      expect(AppEnvironment.parse('prod'), AppEnvironment.production);
    });

    test('rejects unsupported values', () {
      expect(() => AppEnvironment.parse('demo'), throwsFormatException);
    });
  });

  group('LogLevel', () {
    test('parses warning aliases', () {
      expect(LogLevel.parse('warning'), LogLevel.warning);
      expect(LogLevel.parse('warn'), LogLevel.warning);
    });
  });
}
