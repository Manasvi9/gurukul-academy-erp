import '../../../../core/models/result.dart';
import '../entities/class_section.dart';
import '../repositories/student_repository.dart';

final class GetSectionsUseCase {
  const GetSectionsUseCase(this._repository);

  final StudentRepository _repository;

  Future<Result<List<ClassSection>>> call(String classId) {
    return _repository.sections(classId);
  }
}
