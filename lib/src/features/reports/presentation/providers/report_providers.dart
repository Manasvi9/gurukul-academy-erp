import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/bootstrap/app_bootstrap.dart';
import '../../data/repositories/report_repository_impl.dart';
import '../../domain/repositories/report_repository.dart';

final reportRepositoryProvider = Provider<ReportRepository>((ref) {
  return SupabaseReportRepository(ref.watch(supabaseClientProvider));
});
