class ExamMark {
  const ExamMark({
    required this.studentId,
    required this.examSubjectId,
    required this.marks,
    required this.isFinal,
  });

  final String studentId;
  final String examSubjectId;
  final double? marks;
  final bool isFinal;
}
