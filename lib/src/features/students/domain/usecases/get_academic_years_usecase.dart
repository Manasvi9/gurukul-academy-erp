import '../../../../core/models/result.dart';
import '../entities/academic_year.dart';
import '../repositories/student_repository.dart';

final class GetAcademicYearsUseCase {
  const GetAcademicYearsUseCase(this._repository);

  final StudentRepository _repository;

  Future<Result<List<AcademicYear>>> call() {
    return _repository.academicYears();
  }
}
