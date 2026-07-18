final class HomeworkItem {
  const HomeworkItem({
    required this.id,
    required this.academicYearId,
    required this.classId,
    required this.className,
    required this.sectionId,
    required this.sectionName,
    required this.subjectId,
    required this.subjectName,
    required this.dueDate,
    required this.description,
  });

  final String id;
  final String academicYearId;
  final String classId;
  final String className;
  final String sectionId;
  final String sectionName;
  final String subjectId;
  final String subjectName;
  final DateTime dueDate;
  final String description;
}
