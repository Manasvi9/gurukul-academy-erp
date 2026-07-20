enum SalaryPaymentMode {
  cash('Cash'),
  upi('UPI'),
  bankTransfer('Bank Transfer'),
  cheque('Cheque');

  const SalaryPaymentMode(this.label);
  final String label;
}

enum SalaryPaymentStatus {
  pending('Pending'),
  paid('Paid'),
  partial('Partial');

  const SalaryPaymentStatus(this.label);
  final String label;
}
