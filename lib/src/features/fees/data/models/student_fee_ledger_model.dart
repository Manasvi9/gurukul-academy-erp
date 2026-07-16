import '../../domain/entities/student_fee_ledger.dart';

final class StudentFeeLedgerModel extends StudentFeeLedger {
  const StudentFeeLedgerModel({
    required super.studentId,
    required super.studentName,
    required super.srNumber,
    required super.academicYearId,
    required super.academicYear,
    required super.className,
    required super.sectionName,
    required super.classFee,
    required super.transportFee,
    required super.scholarshipDiscount,
    required super.paidAmount,
    required super.outstandingDue,
    required super.isFeeComplete,
  });

  factory StudentFeeLedgerModel.fromJson(Map<String, Object?> json) {
    return StudentFeeLedgerModel(
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String,
      srNumber: json['sr_number'] as String,
      academicYearId: json['academic_year_id'] as String,
      academicYear: json['academic_year'] as String,
      className: json['class_name'] as String,
      sectionName: json['section_name'] as String,
      classFee: json['class_fee'] as num,
      transportFee: json['transport_fee'] as num,
      scholarshipDiscount: json['scholarship_discount'] as num,
      paidAmount: json['paid_amount'] as num,
      outstandingDue: json['outstanding_due'] as num,
      isFeeComplete: json['is_fee_complete'] as bool,
    );
  }
}
