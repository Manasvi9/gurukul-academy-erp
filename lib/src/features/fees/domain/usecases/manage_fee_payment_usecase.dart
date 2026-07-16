import '../../../../core/models/result.dart';
import '../entities/fee_payment_form_data.dart';
import '../repositories/fee_repository.dart';

final class ManageFeePaymentUseCase {
  const ManageFeePaymentUseCase(this._repository);

  final FeeRepository _repository;

  Future<Result<String>> record(FeePaymentFormData data) {
    return _repository.recordPayment(data);
  }

  Future<Result<void>> edit({
    required String paymentId,
    required FeePaymentFormData data,
  }) {
    return _repository.editPayment(paymentId: paymentId, data: data);
  }

  Future<Result<void>> voidPayment({
    required String paymentId,
    required String reason,
  }) {
    return _repository.voidPayment(paymentId: paymentId, reason: reason);
  }
}
