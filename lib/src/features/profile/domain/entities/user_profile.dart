final class UserProfile {
  const UserProfile({
    required this.id,
    required this.role,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.schoolName,
  });

  final String id;
  final String role;
  final String name;
  final String email;
  final String? avatarUrl;
  final String? schoolName;
}
