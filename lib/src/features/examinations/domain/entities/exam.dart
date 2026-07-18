enum ExamType {
  unitTest('unit_test', 'Unit Test'),
  halfYearly('half_yearly', 'Half Yearly'),
  yearly('yearly', 'Yearly'),
  preBoard('pre_board', 'Pre Board');

  const ExamType(this.value, this.label);
  final String value;
  final String label;

  static ExamType fromValue(String value) {
    return ExamType.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExamType.unitTest,
    );
  }
}

enum ExamStatus {
  draft('draft', 'Draft'),
  published('published', 'Published'),
  archived('archived', 'Archived');

  const ExamStatus(this.value, this.label);
  final String value;
  final String label;

  static ExamStatus fromValue(String value) {
    return ExamStatus.values.firstWhere(
      (e) => e.value == value,
      orElse: () => ExamStatus.draft,
    );
  }
}

class Exam {
  const Exam({
    required this.id,
    required this.name,
    required this.type,
    required this.academicYearId,
    required this.classId,
    required this.sectionId,
    required this.startDate,
    this.endDate,
    this.description,
    required this.status,
    this.isArchived = false,
    this.publishedAt,
    this.publishedBy,
  });

  final String id;
  final String name;
  final ExamType type;
  final String academicYearId;
  final String classId;
  final String sectionId;
  final DateTime startDate;
  final DateTime? endDate;
  final String? description;
  final ExamStatus status;
  final bool isArchived;
  final DateTime? publishedAt;
  final String? publishedBy;

  Exam copyWith({
    String? id,
    String? name,
    ExamType? type,
    String? academicYearId,
    String? classId,
    String? sectionId,
    DateTime? startDate,
    DateTime? endDate,
    String? description,
    ExamStatus? status,
    bool? isArchived,
    DateTime? publishedAt,
    String? publishedBy,
  }) {
    return Exam(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      academicYearId: academicYearId ?? this.academicYearId,
      classId: classId ?? this.classId,
      sectionId: sectionId ?? this.sectionId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      description: description ?? this.description,
      status: status ?? this.status,
      isArchived: isArchived ?? this.isArchived,
      publishedAt: publishedAt ?? this.publishedAt,
      publishedBy: publishedBy ?? this.publishedBy,
    );
  }
}
