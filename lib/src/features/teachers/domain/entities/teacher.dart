class Teacher {
  const Teacher({
    required this.id,
    required this.employeeId,
    required this.fullName,
    this.phone,
    this.email,
    required this.isArchived,
  });
  final String id;
  final String employeeId;
  final String fullName;
  final String? phone;
  final String? email;
  final bool isArchived;
}
