import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/salary_payment_enums.dart';
import '../models/salary_models.dart';

final class SalaryRemoteDatasource {
  const SalaryRemoteDatasource(this.client);
  final SupabaseClient client;

  // Profiles
  Future<List<SalaryProfileModel>> getSalaryProfiles(String employeeId) async {
    final response = await client
        .from('salary_profiles')
        .select()
        .eq('staff_id', employeeId);
    return (response as List)
        .map((e) => SalaryProfileModel.fromJson(e))
        .toList();
  }

  // Payroll
  Future<List<SalaryPayrollModel>> getPayrollHistory(String employeeId) async {
    final response = await client
        .from('salary_payrolls')
        .select()
        .eq('staff_id', employeeId)
        .order('year', ascending: false)
        .order('month', ascending: false);
    return (response as List)
        .map((e) => SalaryPayrollModel.fromJson(e))
        .toList();
  }

  Future<void> markPayrollPaid(
    String id,
    SalaryPaymentMode mode,
    String remarks,
  ) async {
    await client.from('salary_payrolls').update({
      'payment_status': 'paid',
      'payment_mode': mode.name,
      'remarks': remarks,
      'payment_date': DateTime.now().toIso8601String(),
    }).eq('id', id);
  }

  // Dashboard Stats
  Future<Map<String, num>> getSalaryDashboardStats() async {
    // Implement complex query or RPC call to Supabase here
    // Returning dummy data for structural completeness
    return {
      'total_payroll': 500000,
      'paid_salaries': 300000,
      'pending_salaries': 200000,
      'total_employees': 50,
    };
  }
}
