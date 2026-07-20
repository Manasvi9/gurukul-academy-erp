import 'salary_payment_enums.dart';

class SalaryProfile {
  const SalaryProfile({
    required this.id,
    required this.employeeId,
    required this.basicSalary,
    required this.effectiveFrom,
    this.effectiveTo,
  });

  final String id;
  final String employeeId;
  final num basicSalary;
  final DateTime effectiveFrom;
  final DateTime? effectiveTo;
}

class SalaryPayroll {
  const SalaryPayroll({
    required this.id,
    required this.employeeId,
    required this.month,
    required this.year,
    required this.workingDays,
    required this.presentDays,
    required this.leaveDays,
    required this.basicSalary,
    required this.attendanceDeduction,
    required this.advanceDeduction,
    required this.netSalary,
    required this.status,
    this.paymentDate,
    this.paymentMode,
    this.remarks,
  });

  final String id;
  final String employeeId;
  final int month;
  final int year;
  final int workingDays;
  final int presentDays;
  final int leaveDays;
  final num basicSalary;
  final num attendanceDeduction;
  final num advanceDeduction;
  final num netSalary;
  final SalaryPaymentStatus status;
  final DateTime? paymentDate;
  final SalaryPaymentMode? paymentMode;
  final String? remarks;
}

class SalaryAdvance {
  const SalaryAdvance({
    required this.id,
    required this.employeeId,
    required this.amount,
    required this.date,
    required this.reason,
    required this.isAdjusted,
  });

  final String id;
  final String employeeId;
  final num amount;
  final DateTime date;
  final String reason;
  final bool isAdjusted;
}
