import '../../domain/entities/login_credentials.dart';

final class CustomAuthLoginRequest {
  const CustomAuthLoginRequest._(this.body);

  factory CustomAuthLoginRequest.parent(ParentLoginCredentials credentials) {
    return CustomAuthLoginRequest._({
      'role': credentials.role.value,
      'mobile_number': credentials.mobileNumber.trim(),
      'password': credentials.password,
    });
  }

  factory CustomAuthLoginRequest.student(StudentLoginCredentials credentials) {
    return CustomAuthLoginRequest._({
      'role': credentials.role.value,
      'sr_number': credentials.srNumber.trim(),
      'password': credentials.password,
    });
  }

  final Map<String, Object?> body;
}
