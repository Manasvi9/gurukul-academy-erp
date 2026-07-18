import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/exam_mark.dart';
import '../domain/entities/exam_subject.dart';
import 'exam_providers.dart';
import 'result_providers.dart';

// Need individual student marks for report card
final studentExamMarksProvider = FutureProvider.family<List<({ExamSubject subject, ExamMark mark})>, ({String examId, String studentId})>((ref, args) async {
  final subjects = await ref.watch(examSubjectsProvider(args.examId).future);
  final allMarks = await ref.watch(allMarksProvider(args.examId).future);
  
  return subjects.map((subject) {
    final marks = allMarks[subject.id] ?? [];
    final mark = marks.firstWhere(
      (m) => m.studentId == args.studentId,
      orElse: () => ExamMark(
          studentId: args.studentId,
          examSubjectId: subject.id,
          marks: null,
          isFinal: false,
      ),
    );
    return (subject: subject, mark: mark);
  }).toList();
});
