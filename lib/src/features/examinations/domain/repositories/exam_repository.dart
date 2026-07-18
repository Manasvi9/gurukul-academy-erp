import '../entities/exam.dart';
import '../entities/exam_mark.dart';
import '../entities/exam_subject.dart';

abstract interface class ExamRepository {
  Future<List<Exam>> list({String? query, String? academicYearId});
  Future<void> createExam(Map<String, Object?> values);
  Future<void> updateExam(String id, Map<String, Object?> values);
  Future<void> deleteExam(String id);
  Future<void> archive(String id);
  Future<void> publish(String id);
  Future<void> unpublish(String id);
  Future<List<ExamSubject>> listSubjects(String examId);
  Future<void> addSubject(Map<String, Object?> values);
  Future<void> updateSubject(String id, Map<String, Object?> values);
  Future<void> deleteSubject(String id);
  Future<List<ExamMark>> listMarks(String examSubjectId);
  Future<void> saveMarks({
    required String examSubjectId,
    required List<ExamMark> marks,
    required bool isFinal,
  });
}
