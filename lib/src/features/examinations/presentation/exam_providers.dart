import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../app/bootstrap/app_bootstrap.dart';
import '../data/exam_repository.dart';
import '../domain/entities/exam.dart';
import '../domain/entities/exam_mark.dart';

final examRepositoryProvider = Provider(
  (ref) => SupabaseExamRepository(ref.watch(supabaseClientProvider)),
);
final examsProvider = FutureProvider<List<Exam>>(
  (ref) => ref.watch(examRepositoryProvider).list(),
);

final examArchiveProvider = Provider<Future<void> Function(String)>((ref) {
  return (examId) async {
    await ref.read(examRepositoryProvider).archive(examId);
    ref.invalidate(examsProvider);
  };
});

final examCreateProvider = Provider<Future<void> Function(Map<String, Object?>)>((ref) {
  return (values) async { await ref.read(examRepositoryProvider).createExam(values); ref.invalidate(examsProvider); };
});
final examUpdateProvider = Provider<Future<void> Function(String, Map<String, Object?>)>((ref) {
  return (id, values) async { await ref.read(examRepositoryProvider).updateExam(id, values); ref.invalidate(examsProvider); };
});
final examDeleteProvider = Provider<Future<void> Function(String)>((ref) {
  return (id) async { await ref.read(examRepositoryProvider).deleteExam(id); ref.invalidate(examsProvider); };
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
