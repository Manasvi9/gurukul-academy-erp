import '../../../../core/models/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../students/domain/entities/student_summary.dart';
import '../../domain/entities/fee_payment.dart';
import '../../domain/entities/fee_payment_form_data.dart';
import '../../domain/entities/student_fee_ledger.dart';
import '../../domain/repositories/fee_repository.dart';
import '../datasources/fee_remote_datasource.dart';

final class FeeRepositoryImpl extends BaseRepository implements FeeRepository {
  const FeeRepositoryImpl(this._remoteDataSource);

  final FeeRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<StudentFeeLedger>>> outstandingLedgers() {
    return guard(_remoteDataSource.outstandingLedgers);
  }

  @override
  Future<Result<StudentFeeLedger>> studentLedger({
    required String studentId,
    required String academicYearId,
  }) {
    return guard(
      () => _remoteDataSource.studentLedger(
        studentId: studentId,
        academicYearId: academicYearId,
      ),
    );
  }

  @override
  Future<Result<List<StudentSummary>>> searchStudents(String query) {
    return guard(() => _remoteDataSource.searchStudents(query));
  }

  @override
  Future<Result<List<FeePayment>>> paymentHistory({
    required String studentId,
    required String academicYearId,
  }) {
    return guard(
      () => _remoteDataSource.paymentHistory(
        studentId: studentId,
        academicYearId: academicYearId,
      ),
    );
  }

  @override
  Future<Result<String>> recordPayment(FeePaymentFormData data) {
    return guard(() => _remoteDataSource.recordPayment(data));
  }

  @override
  Future<Result<void>> editPayment({
    required String paymentId,
    required FeePaymentFormData data,
  }) {
    return guard(
      () => _remoteDataSource.editPayment(paymentId: paymentId, data: data),
    );
  }

  @override
  Future<Result<void>> voidPayment({
    required String paymentId,
    required String reason,
  }) {
    return guard(
      () => _remoteDataSource.voidPayment(
        paymentId: paymentId,
        reason: reason,
      ),
    );
  }

  @override
  Future<Result<void>> markFeeComplete({
    required String studentId,
    required String academicYearId,
    required String note,
  }) {
    return guard(
      () => _remoteDataSource.markFeeComplete(
        studentId: studentId,
        academicYearId: academicYearId,
        note: note,
      ),
    );
  }
}
