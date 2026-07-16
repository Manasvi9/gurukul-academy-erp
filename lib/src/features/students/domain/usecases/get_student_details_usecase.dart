import '../../../../core/models/result.dart';
import '../entities/student_detail.dart';
import '../repositories/student_repository.dart';

final class GetStudentDetailsUseCase {
  const GetStudentDetailsUseCase(this._repository);

  final StudentRepository _repository;

  Future<Result<StudentDetail>> call(String studentId) {
    return _repository.studentDetails(studentId);
  }
}
