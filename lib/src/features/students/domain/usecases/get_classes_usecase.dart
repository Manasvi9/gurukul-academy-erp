import '../../../../core/models/result.dart';
import '../entities/school_class.dart';
import '../repositories/student_repository.dart';

final class GetClassesUseCase {
  const GetClassesUseCase(this._repository);

  final StudentRepository _repository;

  Future<Result<List<SchoolClass>>> call(String academicYearId) {
    return _repository.classes(academicYearId);
  }
}
