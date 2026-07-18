class ExamSubject {
  const ExamSubject({
    required this.id,
    required this.examId,
    required this.subjectId,
    required this.maximumMarks,
    required this.passingMarks,
  });

  final String id;
  final String examId;
  final String subjectId;
  final double maximumMarks;
  final double passingMarks;
}
