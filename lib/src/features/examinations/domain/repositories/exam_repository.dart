import '../entities/exam.dart';
import '../entities/exam_mark.dart';

abstract interface class ExamRepository {
  Future<List<Exam>> list({String? query, String? academicYearId});
  Future<void> createExam(Map<String, Object?> values);
  Future<void> updateExam(String id, Map<String, Object?> values);
  Future<void> deleteExam(String id);
  Future<void> archive(String id);
  Future<void> saveMarks({
    required String examSubjectId,
    required List<ExamMark> marks,
    required bool isFinal,
  });
}
