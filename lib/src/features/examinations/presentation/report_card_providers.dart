import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../domain/entities/exam_mark.dart';
import '../domain/entities/exam_subject.dart';
import 'exam_providers.dart';
import 'result_providers.dart';

/// Defines the structure for a student's mark paired with its respective subject.
typedef StudentReportMark = ({
  ExamSubject subject,
  ExamMark mark,
});

/// Returns every subject in an exam together with the selected student's mark.
/// 
/// If a mark hasn't been entered yet, an empty [ExamMark] is returned.
/// Uses `autoDispose` to clear data from memory once the report card UI is unmounted.
final studentExamMarksProvider =
    FutureProvider.autoDispose.family<
        List<StudentReportMark>,
        ({String examId, String studentId})>((ref, args) async {
  final subjects = await ref.watch(examSubjectsProvider(args.examId).future);
  final allMarks = await ref.watch(allMarksProvider(args.examId).future);

  final result = <StudentReportMark>[];

  for (final subject in subjects) {
    // Map conversion to ensure O(1) lookups instead of repeated list scanning
    final marksByStudent = {
      for (final mark in (allMarks[subject.id] ?? const <ExamMark>[]))
        mark.studentId: mark,
    };

    final mark = marksByStudent[args.studentId] ??
        _emptyMark(
          studentId: args.studentId,
          examSubjectId: subject.id,
        );

    result.add((subject: subject, mark: mark));
  }

  return result;
});

/// Generates a structured structural fallback instance when records are unassigned.
ExamMark _emptyMark({
  required String studentId,
  required String examSubjectId,
}) {
  return ExamMark(
    studentId: studentId,
    examSubjectId: examSubjectId,
    marks: null,
    isFinal: false,
  );
}