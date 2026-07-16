import '../../../../core/models/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../datasources/dashboard_remote_datasource.dart';

final class DashboardRepositoryImpl extends BaseRepository
    implements DashboardRepository {
  const DashboardRepositoryImpl(this._remoteDataSource);

  final DashboardRemoteDataSource _remoteDataSource;

  @override
  Future<Result<DashboardSummary>> summary() {
    return guard(_remoteDataSource.summary);
  }
}
