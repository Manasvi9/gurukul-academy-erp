enum FeePaymentStatus {
  posted('posted'),
  voided('void');

  const FeePaymentStatus(this.value);

  final String value;
}

class FeePayment {
  const FeePayment({
    required this.id,
    required this.studentId,
    required this.academicYearId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    required this.referenceNumber,
    required this.note,
    required this.status,
  });

  final String id;
  final String studentId;
  final String academicYearId;
  final num amount;
  final DateTime paymentDate;
  final String paymentMode;
  final String? referenceNumber;
  final String? note;
  final FeePaymentStatus status;
}
