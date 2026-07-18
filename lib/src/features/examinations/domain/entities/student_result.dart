class StudentResult {
  const StudentResult({
    required this.studentId,
    required this.studentName,
    required this.rollNumber,
    required this.totalObtained,
    required this.totalMaximum,
    required this.percentage,
    required this.isPass,
  });

  final String studentId;
  final String studentName;
  final int rollNumber;
  final double totalObtained;
  final double totalMaximum;
  final double percentage;
  final bool isPass;
}
