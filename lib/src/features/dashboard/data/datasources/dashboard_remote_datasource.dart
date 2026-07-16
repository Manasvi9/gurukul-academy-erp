import 'package:supabase_flutter/supabase_flutter.dart';

import '../models/dashboard_summary_model.dart';

abstract interface class DashboardRemoteDataSource {
  Future<DashboardSummaryModel> summary();
}

final class SupabaseDashboardRemoteDataSource
    implements DashboardRemoteDataSource {
  SupabaseDashboardRemoteDataSource(
    this._client, {
    this.customAccessToken,
  });

  final SupabaseClient _client;
  final String? customAccessToken;

  @override
  Future<DashboardSummaryModel> summary() async {
    if (customAccessToken != null) {
      final response = await _client.functions.invoke(
        'dashboard-access',
        headers: {'Authorization': 'Bearer $customAccessToken'},
      );
      if (response.status < 200 || response.status >= 300) {
        final data = response.data;
        if (data is Map && data['error'] is String) {
          throw AuthException(data['error'] as String);
        }
        throw AuthException('Dashboard request failed.');
      }
      return DashboardSummaryModel.fromJson(
        response.data as Map<String, Object?>,
      );
    }

    final response = await _client.rpc<Map<String, dynamic>>(
      'get_staff_dashboard_summary',
    );
    return DashboardSummaryModel.fromJson(
      response.cast<String, Object?>(),
    );
  }
}
