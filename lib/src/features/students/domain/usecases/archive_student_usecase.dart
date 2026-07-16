import '../../../../core/models/result.dart';
import '../repositories/student_repository.dart';

final class ArchiveStudentUseCase {
  const ArchiveStudentUseCase(this._repository);

  final StudentRepository _repository;

  Future<Result<void>> call(String studentId) {
    return _repository.archiveStudent(studentId);
  }
}
