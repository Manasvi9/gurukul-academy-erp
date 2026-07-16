final class FeePaymentFormData {
  const FeePaymentFormData({
    required this.studentId,
    required this.academicYearId,
    required this.amount,
    required this.paymentDate,
    required this.paymentMode,
    required this.referenceNumber,
    required this.note,
  });

  final String studentId;
  final String academicYearId;
  final num amount;
  final DateTime paymentDate;
  final String paymentMode;
  final String referenceNumber;
  final String note;
}
