import '../../../../core/models/result.dart';
import '../entities/student_form_data.dart';
import '../repositories/student_repository.dart';

final class SaveStudentUseCase {
  const SaveStudentUseCase(this._repository);

  final StudentRepository _repository;

  Future<Result<String>> create(StudentFormData data) {
    return _repository.createStudent(data);
  }

  Future<Result<void>> update({
    required String studentId,
    required StudentFormData data,
  }) {
    return _repository.updateStudent(studentId: studentId, data: data);
  }
}
