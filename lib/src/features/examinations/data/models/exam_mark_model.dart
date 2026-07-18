import '../../domain/entities/exam_mark.dart';

final class ExamMarkModel extends ExamMark {
  const ExamMarkModel({
    required super.studentId,
    required super.examSubjectId,
    required super.marks,
    required super.isFinal,
  });

  factory ExamMarkModel.fromJson(Map<String, Object?> json) => ExamMarkModel(
        studentId: json['student_id'] as String,
        examSubjectId: json['exam_subject_id'] as String,
        marks: (json['marks'] as num?)?.toDouble(),
        isFinal: json['is_final'] as bool,
      );

  Map<String, Object?> toJson() => {
        'student_id': studentId,
        'exam_subject_id': examSubjectId,
        'marks': marks,
        'is_final': isFinal,
      };
}
