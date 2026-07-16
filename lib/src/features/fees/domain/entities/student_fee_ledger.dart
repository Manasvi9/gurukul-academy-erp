final class StudentFeeLedger {
  const StudentFeeLedger({
    required this.studentId,
    required this.studentName,
    required this.srNumber,
    required this.academicYearId,
    required this.academicYear,
    required this.className,
    required this.sectionName,
    required this.classFee,
    required this.transportFee,
    required this.scholarshipDiscount,
    required this.paidAmount,
    required this.outstandingDue,
    required this.isFeeComplete,
  });

  final String studentId;
  final String studentName;
  final String srNumber;
  final String academicYearId;
  final String academicYear;
  final String className;
  final String sectionName;
  final num classFee;
  final num transportFee;
  final num scholarshipDiscount;
  final num paidAmount;
  final num outstandingDue;
  final bool isFeeComplete;
}
