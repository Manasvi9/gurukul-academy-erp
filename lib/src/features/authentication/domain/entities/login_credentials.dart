import 'auth_role.dart';

sealed class LoginCredentials {
  const LoginCredentials({required this.role, required this.password});

  final AuthRole role;
  final String password;
}

final class StaffLoginCredentials extends LoginCredentials {
  const StaffLoginCredentials({
    required this.email,
    required super.role,
    required super.password,
  });

  final String email;
}

final class ParentLoginCredentials extends LoginCredentials {
  const ParentLoginCredentials({
    required this.mobileNumber,
    required super.password,
  }) : super(role: AuthRole.parent);

  final String mobileNumber;
}

final class StudentLoginCredentials extends LoginCredentials {
  const StudentLoginCredentials({
    required this.srNumber,
    required super.password,
  }) : super(role: AuthRole.student);

  final String srNumber;
}
