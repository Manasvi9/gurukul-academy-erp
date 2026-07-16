import '../../../../core/models/result.dart';
import '../entities/student_summary.dart';
import '../repositories/student_repository.dart';

final class GetStudentsBySectionUseCase {
  const GetStudentsBySectionUseCase(this._repository);

  final StudentRepository _repository;

  Future<Result<List<StudentSummary>>> call({
    required String academicYearId,
    required String classId,
    required String sectionId,
  }) {
    return _repository.studentsBySection(
      academicYearId: academicYearId,
      classId: classId,
      sectionId: sectionId,
    );
  }
}
