import '../../domain/entities/exam.dart';

final class ExamModel extends Exam {
  const ExamModel({
    required super.id,
    required super.name,
    required super.type,
    required super.academicYearId,
    required super.classId,
    required super.sectionId,
    required super.startDate,
    super.endDate,
    super.description,
    required super.status,
    super.isArchived,
    super.publishedAt,
    super.publishedBy,
  });

  factory ExamModel.fromJson(Map<String, Object?> json) => ExamModel(
        id: json['id'] as String,
        name: json['name'] as String,
        type: ExamType.fromValue(json['type'] as String),
        academicYearId: json['academic_year_id'] as String,
        classId: json['class_id'] as String,
        sectionId: json['section_id'] as String,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: json['end_date'] != null
            ? DateTime.parse(json['end_date'] as String)
            : null,
        description: json['description'] as String?,
        status: ExamStatus.fromValue(json['status'] as String),
        isArchived: json['is_archived'] as bool? ?? false,
        publishedAt: json['published_at'] != null
            ? DateTime.parse(json['published_at'] as String)
            : null,
        publishedBy: json['published_by'] as String?,
      );

  Map<String, Object?> toJson() => {
        'name': name,
        'type': type.value,
        'academic_year_id': academicYearId,
        'class_id': classId,
        'section_id': sectionId,
        'start_date': startDate.toIso8601String(),
        'end_date': endDate?.toIso8601String(),
        'description': description,
        'status': status.value,
        'is_archived': isArchived,
        'published_at': publishedAt?.toIso8601String(),
        'published_by': publishedBy,
      };
}
