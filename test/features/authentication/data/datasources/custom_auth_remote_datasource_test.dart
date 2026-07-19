import 'package:flutter_test/flutter_test.dart';
import 'package:gurukul_academy_erp/src/features/authentication/data/datasources/custom_auth_remote_datasource.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockFunctionsClient extends Mock implements FunctionsClient {}

void main() {
  late MockSupabaseClient mockSupabaseClient;
  late MockFunctionsClient mockFunctionsClient;
  late SupabaseFunctionCustomAuthRemoteDataSource dataSource;

  setUp(() {
    mockSupabaseClient = MockSupabaseClient();
    mockFunctionsClient = MockFunctionsClient();

    when(() => mockSupabaseClient.functions).thenReturn(mockFunctionsClient);

    dataSource = SupabaseFunctionCustomAuthRemoteDataSource(mockSupabaseClient);
  });

  group('logout', () {
    test('should call functions.invoke with correct parameters on success',
        () async {
      // Arrange
      final refreshToken = 'test_refresh_token';
      when(() => mockFunctionsClient.invoke(
            'custom-auth-logout',
            body: any(named: 'body'),
          ),).thenAnswer(
        (_) async => FunctionResponse(
          data: {'ok': true},
          status: 200,
        ),
      );

      // Act
      await dataSource.logout(refreshToken);

      // Assert
      verify(() => mockFunctionsClient.invoke(
            'custom-auth-logout',
            body: {
              'refresh_token': refreshToken,
            },
          ),).called(1);
    });

    test('should throw AuthException when logout fails', () async {
      // Arrange
      final refreshToken = 'test_refresh_token';
      when(() => mockFunctionsClient.invoke(
            'custom-auth-logout',
            body: any(named: 'body'),
          ),).thenAnswer(
        (_) async => FunctionResponse(
          data: {'error': 'Logout failed'},
          status: 500,
        ),
      );

      // Act & Assert
      expect(
        () => dataSource.logout(refreshToken),
        throwsA(isA<AuthException>()),
      );
    });
  });
}
