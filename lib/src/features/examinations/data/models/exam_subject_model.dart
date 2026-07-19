import '../../domain/entities/exam_subject.dart';

final class ExamSubjectModel extends ExamSubject {
  const ExamSubjectModel({
    required super.id,
    required super.examId,
    required super.subjectId,
    required super.maximumMarks,
    required super.passingMarks,
  });

  factory ExamSubjectModel.fromJson(Map<String, Object?> json) =>
      ExamSubjectModel(
        id: json['id'] as String,
        examId: json['exam_id'] as String,
        subjectId: json['subject_id'] as String,
        maximumMarks: (json['maximum_marks'] as num).toDouble(),
        passingMarks: (json['passing_marks'] as num).toDouble(),
      );

  Map<String, Object?> toJson() => {
        'exam_id': examId,
        'subject_id': subjectId,
        'maximum_marks': maximumMarks,
        'passing_marks': passingMarks,
      };
}
