import '../../../../core/models/result.dart';
import '../../../students/domain/entities/student_summary.dart';
import '../entities/fee_payment.dart';
import '../entities/fee_payment_form_data.dart';
import '../entities/student_fee_ledger.dart';

abstract interface class FeeRepository {
  Future<Result<List<StudentFeeLedger>>> outstandingLedgers();

  Future<Result<StudentFeeLedger>> studentLedger({
    required String studentId,
    required String academicYearId,
  });

  Future<Result<List<StudentSummary>>> searchStudents(String query);

  Future<Result<List<FeePayment>>> paymentHistory({
    required String studentId,
    required String academicYearId,
  });

  Future<Result<String>> recordPayment(FeePaymentFormData data);

  Future<Result<void>> editPayment({
    required String paymentId,
    required FeePaymentFormData data,
  });

  Future<Result<void>> voidPayment({
    required String paymentId,
    required String reason,
  });

  Future<Result<void>> markFeeComplete({
    required String studentId,
    required String academicYearId,
    required String note,
  });
}
