import '../../../../core/models/result.dart';
import '../entities/class_fee_structure.dart';
import '../repositories/student_repository.dart';

final class GetStudentFeeStructureUseCase {
  const GetStudentFeeStructureUseCase(this._repository);

  final StudentRepository _repository;

  Future<Result<ClassFeeStructure>> call({
    required String academicYearId,
    required String classId,
  }) {
    return _repository.feeStructure(
      academicYearId: academicYearId,
      classId: classId,
    );
  }
}
