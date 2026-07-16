import '../../../../core/models/result.dart';
import '../entities/student_summary.dart';
import '../repositories/student_repository.dart';

final class GetRecentlyViewedStudentsUseCase {
  const GetRecentlyViewedStudentsUseCase(this._repository);

  final StudentRepository _repository;

  Future<Result<List<StudentSummary>>> call() {
    return _repository.recentlyViewedStudents();
  }
}
