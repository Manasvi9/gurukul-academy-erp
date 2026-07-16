import '../../../../core/models/result.dart';
import '../entities/dashboard_summary.dart';

abstract interface class DashboardRepository {
  Future<Result<DashboardSummary>> summary();
}
