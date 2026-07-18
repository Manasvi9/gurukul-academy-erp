class StudentSummary {
  const StudentSummary({
    required this.id,
    required this.rollNumber,
    required this.name,
    required this.srNumber,
    required this.feeDue,
    required this.attendancePercentage,
    required this.className,
    required this.sectionName,
  });

  final String id;
  final int? rollNumber;
  final String name;
  final String srNumber;
  final num feeDue;
  final num? attendancePercentage;
  final String className;
  final String sectionName;
}
