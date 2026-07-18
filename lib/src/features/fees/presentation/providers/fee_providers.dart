import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../app/bootstrap/app_bootstrap.dart';
import '../../../students/domain/entities/student_summary.dart';
import '../../data/datasources/fee_remote_datasource.dart';
import '../../data/repositories/fee_repository_impl.dart';
import '../../domain/entities/fee_payment.dart';
import '../../domain/entities/fee_payment_form_data.dart';
import '../../domain/entities/student_fee_ledger.dart';
import '../../domain/repositories/fee_repository.dart';
import '../../domain/usecases/get_fee_dashboard_usecase.dart';
import '../../domain/usecases/manage_fee_payment_usecase.dart';

final feeRemoteDataSourceProvider = Provider<FeeRemoteDataSource>((ref) {
  return SupabaseFeeRemoteDataSource(ref.watch(supabaseClientProvider));
});

final feeRepositoryProvider = Provider<FeeRepository>((ref) {
  return FeeRepositoryImpl(ref.watch(feeRemoteDataSourceProvider));
});

final feeDashboardUseCaseProvider = Provider<GetFeeDashboardUseCase>((ref) {
  return GetFeeDashboardUseCase(ref.watch(feeRepositoryProvider));
});

final manageFeePaymentUseCaseProvider = Provider<ManageFeePaymentUseCase>((
  ref,
) {
  return ManageFeePaymentUseCase(ref.watch(feeRepositoryProvider));
});

final feeDashboardProvider =
    FutureProvider<List<StudentFeeLedger>>((ref) async {
  final result = await ref.watch(feeDashboardUseCaseProvider)();
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final feeStudentSearchProvider = StateNotifierProvider.autoDispose<
    FeeStudentSearchController, AsyncValue<List<StudentSummary>>>((ref) {
  return FeeStudentSearchController(ref.watch(feeRepositoryProvider));
});

final studentFeeLedgerProvider =
    FutureProvider.family<StudentFeeLedger, FeeLedgerRequest>(
        (ref, request) async {
  final result = await ref.watch(feeRepositoryProvider).studentLedger(
        studentId: request.studentId,
        academicYearId: request.academicYearId,
      );
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final feePaymentHistoryProvider =
    FutureProvider.family<List<FeePayment>, FeeLedgerRequest>(
        (ref, request) async {
  final result = await ref.watch(feeRepositoryProvider).paymentHistory(
        studentId: request.studentId,
        academicYearId: request.academicYearId,
      );
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final feePaymentControllerProvider =
    StateNotifierProvider.autoDispose<FeePaymentController, AsyncValue<void>>((
  ref,
) {
  return FeePaymentController(
    manageFeePaymentUseCase: ref.watch(manageFeePaymentUseCaseProvider),
    repository: ref.watch(feeRepositoryProvider),
  );
});

final class FeeLedgerRequest {
  const FeeLedgerRequest({
    required this.studentId,
    required this.academicYearId,
  });

  final String studentId;
  final String academicYearId;

  @override
  bool operator ==(Object other) {
    return other is FeeLedgerRequest &&
        other.studentId == studentId &&
        other.academicYearId == academicYearId;
  }

  @override
  int get hashCode => Object.hash(studentId, academicYearId);
}

final class FeeStudentSearchController
    extends StateNotifier<AsyncValue<List<StudentSummary>>> {
  FeeStudentSearchController(this._repository)
      : super(const AsyncValue.data([]));

  final FeeRepository _repository;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }
    state = const AsyncValue.loading();
    final result = await _repository.searchStudents(query);
    state = result.when(
      success: AsyncValue.data,
      failure: (failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
    );
  }
}

final class FeePaymentController extends StateNotifier<AsyncValue<void>> {
  FeePaymentController({
    required ManageFeePaymentUseCase manageFeePaymentUseCase,
    required FeeRepository repository,
  })  : _manageFeePaymentUseCase = manageFeePaymentUseCase,
        _repository = repository,
        super(const AsyncValue.data(null));

  final ManageFeePaymentUseCase _manageFeePaymentUseCase;
  final FeeRepository _repository;

  Future<bool> record(FeePaymentFormData data) async {
    state = const AsyncValue.loading();
    final result = await _manageFeePaymentUseCase.record(data);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
    );
  }

  Future<bool> markComplete({
    required String studentId,
    required String academicYearId,
    required String note,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.markFeeComplete(
      studentId: studentId,
      academicYearId: academicYearId,
      note: note,
    );
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
    );
  }
}
