import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../students/presentation/providers/student_providers.dart';
import '../domain/entities/exam.dart';
import '../domain/entities/exam_mark.dart';
import '../domain/entities/student_result.dart';
import 'exam_providers.dart';

final allMarksProvider =
    FutureProvider.family<Map<String, List<ExamMark>>, String>(
        (ref, examId) async {
  final subjects = await ref.watch(examSubjectsProvider(examId).future);
  final marksMap = <String, List<ExamMark>>{};
  for (final subject in subjects) {
    marksMap[subject.id] =
        await ref.watch(examMarksProvider(subject.id).future);
  }
  return marksMap;
});

final studentResultsProvider =
    FutureProvider.family<List<StudentResult>, Exam>((ref, exam) async {
  final subjects = await ref.watch(examSubjectsProvider(exam.id).future);
  final students = await ref.watch(
    studentListProvider(
      StudentListRequest(
        academicYearId: exam.academicYearId,
        classId: exam.classId,
        sectionId: exam.sectionId,
      ),
    ).future,
  );
  final allMarks = await ref.watch(allMarksProvider(exam.id).future);

  final results = <StudentResult>[];

  for (final student in students) {
    double totalObtained = 0;
    double totalMaximum = 0;
    bool isPass = true;

    for (final subject in subjects) {
      final marks = allMarks[subject.id] ?? [];
      final mark = marks.firstWhere(
        (m) => m.studentId == student.id,
        orElse: () => ExamMark(
          studentId: student.id,
          examSubjectId: subject.id,
          marks: null,
          isFinal: false,
        ),
      );

      // Absent check
      if (mark.isFinal && mark.marks == null) {
        isPass = false;
        totalMaximum += subject.maximumMarks;
        continue;
      }

      // Pass marks check
      if (mark.isFinal && mark.marks! < subject.passingMarks) {
        isPass = false;
      }

      if (mark.marks != null) {
        totalObtained += mark.marks!;
      }
      totalMaximum += subject.maximumMarks;
    }

    final percentage =
        totalMaximum > 0 ? (totalObtained / totalMaximum) * 100 : 0.0;

    results.add(
      StudentResult(
        studentId: student.id,
        studentName: student.name,
        rollNumber: student.rollNumber ?? 0,
        totalObtained: totalObtained,
        totalMaximum: totalMaximum,
        percentage: percentage,
        isPass: isPass,
      ),
    );
  }
  return results;
});

final resultFilterProvider = StateProvider<String>((ref) => 'All');
final resultSortProvider = StateProvider<String>((ref) => 'Roll Number');
