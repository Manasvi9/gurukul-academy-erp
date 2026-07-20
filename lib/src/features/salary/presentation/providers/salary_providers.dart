import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../data/datasources/salary_remote_datasource.dart';
import '../../data/repositories/salary_repository_impl.dart';
import '../../domain/entities/salary_entities.dart';
import '../../domain/entities/salary_payment_enums.dart';
import '../../domain/repositories/salary_repository.dart';

// Assuming global supabase provider exists in the core app module
final supabaseClientProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

final salaryRepositoryProvider = Provider<SalaryRepository>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return SalaryRepositoryImpl(SalaryRemoteDatasource(supabase));
});

// Dashboard
final salaryDashboardStatsProvider = FutureProvider<Map<String, num>>((ref) {
  return ref.watch(salaryRepositoryProvider).getSalaryDashboardStats();
});

// Employee specific lists
final salaryPayrollListProvider =
    FutureProvider.family<List<SalaryPayroll>, String>((ref, employeeId) {
  return ref.watch(salaryRepositoryProvider).getPayrollHistory(employeeId);
});

final salaryProfileListProvider =
    FutureProvider.family<List<SalaryProfile>, String>((ref, employeeId) {
  return ref.watch(salaryRepositoryProvider).getSalaryProfiles(employeeId);
});

final salaryAdvanceHistoryProvider =
    FutureProvider.family<List<SalaryAdvance>, String>((ref, employeeId) {
  return ref.watch(salaryRepositoryProvider).getSalaryAdvances(employeeId);
});

// Controller for payments
final salaryPaymentControllerProvider =
    AsyncNotifierProvider<SalaryPaymentController, void>(
        SalaryPaymentController.new,);

final class SalaryPaymentController extends AsyncNotifier<void> {
  @override
  FutureOr<void> build() {}

  Future<void> markPaid(String payrollId, SalaryPaymentMode mode, String remarks) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await ref.read(salaryRepositoryProvider).markPayrollPaid(payrollId, mode, remarks);
    });
  }
}

// Filters/Search
final salaryFilterMonthProvider = NotifierProvider<FilterNotifier<int>, int?>(() => FilterNotifier<int>());
final salaryFilterYearProvider = NotifierProvider<FilterNotifier<int>, int?>(() => FilterNotifier<int>());
final salaryFilterEmployeeProvider = NotifierProvider<FilterNotifier<String>, String?>(() => FilterNotifier<String>());
final salaryFilterStatusProvider = NotifierProvider<FilterNotifier<SalaryPaymentStatus>, SalaryPaymentStatus?>(() => FilterNotifier<SalaryPaymentStatus>());

class FilterNotifier<T> extends Notifier<T?> {
  @override
  T? build() => null;
  void set(T? value) => state = value;
}
