enum AuthRole {
  systemAdmin('system_admin', 'Admin'),
  director('director', 'Director'),
  principal('principal', 'Principal'),
  teacher('teacher', 'Teacher'),
  parent('parent', 'Parent'),
  student('student', 'Student');

  const AuthRole(this.value, this.label);

  final String value;
  final String label;

  bool get usesSupabaseAuth {
    return switch (this) {
      AuthRole.systemAdmin ||
      AuthRole.director ||
      AuthRole.principal ||
      AuthRole.teacher =>
        true,
      AuthRole.parent || AuthRole.student => false,
    };
  }

  static AuthRole fromValue(String value) {
    return AuthRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => throw FormatException('Unsupported role: $value'),
    );
  }
}
