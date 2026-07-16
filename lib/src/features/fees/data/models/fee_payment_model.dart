import '../../domain/entities/fee_payment.dart';

final class FeePaymentModel extends FeePayment {
  const FeePaymentModel({
    required super.id,
    required super.studentId,
    required super.academicYearId,
    required super.amount,
    required super.paymentDate,
    required super.paymentMode,
    required super.referenceNumber,
    required super.note,
    required super.status,
  });

  factory FeePaymentModel.fromJson(Map<String, Object?> json) {
    return FeePaymentModel(
      id: json['id'] as String,
      studentId: json['student_id'] as String,
      academicYearId: json['academic_year_id'] as String,
      amount: json['amount'] as num,
      paymentDate: DateTime.parse(json['payment_date'] as String),
      paymentMode: json['payment_mode'] as String,
      referenceNumber: json['reference_number'] as String?,
      note: json['note'] as String?,
      status: (json['status'] as String) == 'void'
          ? FeePaymentStatus.voided
          : FeePaymentStatus.posted,
    );
  }
}
