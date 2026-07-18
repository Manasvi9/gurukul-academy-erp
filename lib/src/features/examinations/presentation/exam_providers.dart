import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../app/bootstrap/app_bootstrap.dart';
import '../data/exam_repository.dart';
import '../domain/entities/exam.dart';
import '../domain/entities/exam_mark.dart';
import '../domain/entities/exam_subject.dart';

final examRepositoryProvider = Provider(
  (ref) => SupabaseExamRepository(ref.watch(supabaseClientProvider)),
);

final examSearchQueryProvider = StateProvider<String>((ref) => '');
final examAcademicYearFilterProvider = StateProvider<String?>((ref) => null);

final examsProvider = FutureProvider<List<Exam>>((ref) {
  final query = ref.watch(examSearchQueryProvider);
  final academicYearId = ref.watch(examAcademicYearFilterProvider);
  return ref.watch(examRepositoryProvider).list(
        query: query,
        academicYearId: academicYearId,
      );
});

final examArchiveProvider = Provider<Future<void> Function(String)>((ref) {
  return (examId) async {
    await ref.read(examRepositoryProvider).archive(examId);
    ref.invalidate(examsProvider);
  };
});

final examCreateProvider =
    Provider<Future<void> Function(Map<String, Object?>)>((ref) {
  return (values) async {
    await ref.read(examRepositoryProvider).createExam(values);
    ref.invalidate(examsProvider);
  };
});

final examUpdateProvider =
    Provider<Future<void> Function(String, Map<String, Object?>)>((ref) {
  return (id, values) async {
    await ref.read(examRepositoryProvider).updateExam(id, values);
    ref.invalidate(examsProvider);
  };
});

final examDeleteProvider = Provider<Future<void> Function(String)>((ref) {
  return (id) async {
    await ref.read(examRepositoryProvider).deleteExam(id);
    ref.invalidate(examsProvider);
  };
});

final examSubjectsProvider = FutureProvider.family<List<ExamSubject>, String>((ref, examId) {
  return ref.watch(examRepositoryProvider).listSubjects(examId);
});

final examSubjectAddProvider =
    Provider<Future<void> Function(String, Map<String, Object?>)>((ref) {
  return (examId, values) async {
    await ref.read(examRepositoryProvider).addSubject(values);
    ref.invalidate(examSubjectsProvider(examId));
  };
});

final examSubjectUpdateProvider =
    Provider<Future<void> Function(String, String, Map<String, Object?>)>((ref) {
  return (examId, id, values) async {
    await ref.read(examRepositoryProvider).updateSubject(id, values);
    ref.invalidate(examSubjectsProvider(examId));
  };
});

final examSubjectDeleteProvider =
    Provider<Future<void> Function(String, String)>((ref) {
  return (examId, id) async {
    await ref.read(examRepositoryProvider).deleteSubject(id);
    ref.invalidate(examSubjectsProvider(examId));
  };
});

final examMarksSaveProvider =
    Provider<Future<void> Function(String, List<ExamMark>, bool)>((ref) {
  return (examSubjectId, marks, isFinal) async {
    await ref.read(examRepositoryProvider).saveMarks(
          examSubjectId: examSubjectId,
          marks: marks,
          isFinal: isFinal,
        );
    ref.invalidate(examsProvider);
  };
});
