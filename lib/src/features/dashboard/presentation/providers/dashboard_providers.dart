import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/bootstrap/app_bootstrap.dart';
import '../../../authentication/domain/entities/auth_role.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/dashboard_remote_datasource.dart';
import '../../data/repositories/dashboard_repository_impl.dart';
import '../../domain/entities/dashboard_summary.dart';
import '../../domain/repositories/dashboard_repository.dart';
import '../../domain/usecases/get_dashboard_summary_usecase.dart';

final dashboardRemoteDataSourceProvider = Provider<DashboardRemoteDataSource>((
  ref,
) {
  final authState = ref.watch(authControllerProvider);
  final role = authState.user?.role;
  final customAccessToken =
      role == AuthRole.parent || role == AuthRole.student
          ? authState.session?.accessToken
          : null;

  return SupabaseDashboardRemoteDataSource(
    ref.watch(supabaseClientProvider),
    customAccessToken: customAccessToken,
  );
});

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) {
  return DashboardRepositoryImpl(ref.watch(dashboardRemoteDataSourceProvider));
});

final dashboardSummaryUseCaseProvider = Provider<GetDashboardSummaryUseCase>((
  ref,
) {
  return GetDashboardSummaryUseCase(ref.watch(dashboardRepositoryProvider));
});

final dashboardSummaryProvider = FutureProvider<DashboardSummary>((ref) async {
  final result = await ref.watch(dashboardSummaryUseCaseProvider)();
  return result.when(
    success: (summary) => summary,
    failure: (failure) => throw failure.message,
  );
});
