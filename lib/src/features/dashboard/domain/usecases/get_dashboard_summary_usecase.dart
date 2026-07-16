import '../../../../core/models/result.dart';
import '../entities/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

final class GetDashboardSummaryUseCase {
  const GetDashboardSummaryUseCase(this._repository);

  final DashboardRepository _repository;

  Future<Result<DashboardSummary>> call() {
    return _repository.summary();
  }
}
