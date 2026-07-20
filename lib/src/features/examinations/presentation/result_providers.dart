import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../students/presentation/providers/student_providers.dart';
import '../domain/entities/exam.dart';
import '../domain/entities/exam_mark.dart';
import '../domain/entities/student_result.dart';
import 'exam_providers.dart';

/// Supported criteria for filtering processed student outcomes.
enum ResultFilter { all, passed, failed }

/// Supported sorting dimensions for order normalization in list metrics.
enum ResultSort { rollNumber, name, percentage }

/// Computes the marks for every subject in an exam, grouped by exam subject ID.
final allMarksProvider =
    FutureProvider.autoDispose.family<Map<String, List<ExamMark>>, String>(
        (ref, examId) async {
  final subjects = await ref.watch(examSubjectsProvider(examId).future);
  final marksMap = <String, List<ExamMark>>{};
  
  for (final subject in subjects) {
    marksMap[subject.id] =
        await ref.watch(examMarksProvider(subject.id).future);
  }
  return marksMap;
});

/// Calculates final results for every student in the selected examination.
final studentResultsProvider =
    FutureProvider.autoDispose.family<List<StudentResult>, Exam>((ref, exam) async {
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

  // Optimize subject-level lookup maps to avoid nested loop scan overhead
  final subjectStudentMarksLookups = <String, Map<String, ExamMark>>{
    for (final subject in subjects)
      subject.id: {
        for (final mark in (allMarks[subject.id] ?? <ExamMark>[]))
          mark.studentId: mark,
      },
  };

  for (final student in students) {
    double totalObtained = 0;
    double totalMaximum = 0;
    bool isPass = true;

    for (final subject in subjects) {
      final marksLookup = subjectStudentMarksLookups[subject.id] ?? const {};
      final mark = marksLookup[student.id] ??
          ExamMark(
            studentId: student.id,
            examSubjectId: subject.id,
            marks: null,
            isFinal: false,
          );

      // Absent verification rule
      if (mark.isFinal && mark.marks == null) {
        isPass = false;
        totalMaximum += subject.maximumMarks;
        continue;
      }

      // Performance validation rule
      if (mark.isFinal && mark.marks! < subject.passingMarks) {
        isPass = false;
      }

      if (mark.marks != null) {
        totalObtained += mark.marks!;
      }
      totalMaximum += subject.maximumMarks;
    }

    results.add(
      StudentResult(
        studentId: student.id,
        studentName: student.name,
        rollNumber: student.rollNumber ?? 0,
        totalObtained: totalObtained,
        totalMaximum: totalMaximum,
        percentage: _calculatePercentage(totalObtained, totalMaximum),
        isPass: isPass,
      ),
    );
  }
  return results;
});

/// Tracks the active selection matching criteria filter for examination results view.
final resultFilterProvider =
    NotifierProvider<ResultFilterNotifier, ResultFilter>(
  ResultFilterNotifier.new,
);

final resultSortProvider =
    NotifierProvider<ResultSortNotifier, ResultSort>(
  ResultSortNotifier.new,
);

class ResultFilterNotifier extends Notifier<ResultFilter> {
  @override
  ResultFilter build() => ResultFilter.all;

  void set(ResultFilter value) {
    state = value;
  }
}

class ResultSortNotifier extends Notifier<ResultSort> {
  @override
  ResultSort build() => ResultSort.rollNumber;

  void set(ResultSort value) {
    state = value;
  }
}

/// Helper expression yielding score performance values without mathematical undefined errors.
double _calculatePercentage(double obtained, double maximum) {
  return maximum == 0 ? 0.0 : (obtained / maximum) * 100.0;
}
