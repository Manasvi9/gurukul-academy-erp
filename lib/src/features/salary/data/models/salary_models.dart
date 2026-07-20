import '../../domain/entities/salary_entities.dart';
import '../../domain/entities/salary_payment_enums.dart';

final class SalaryProfileModel extends SalaryProfile {
  const SalaryProfileModel({
    required super.id,
    required super.employeeId,
    required super.basicSalary,
    required super.effectiveFrom,
    super.effectiveTo,
  });

  factory SalaryProfileModel.fromJson(Map<String, dynamic> json) {
    return SalaryProfileModel(
      id: json['id'],
      employeeId: json['employee_id'],
      basicSalary: json['basic_salary'],
      effectiveFrom: DateTime.parse(json['effective_from']),
      effectiveTo: json['effective_to'] != null
          ? DateTime.parse(json['effective_to'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'basic_salary': basicSalary,
      'effective_from': effectiveFrom.toIso8601String(),
      'effective_to': effectiveTo?.toIso8601String(),
    };
  }
}

final class SalaryPayrollModel extends SalaryPayroll {
  const SalaryPayrollModel({
    required super.id,
    required super.employeeId,
    required super.month,
    required super.year,
    required super.workingDays,
    required super.presentDays,
    required super.leaveDays,
    required super.basicSalary,
    required super.attendanceDeduction,
    required super.advanceDeduction,
    required super.netSalary,
    required super.status,
    super.paymentDate,
    super.paymentMode,
    super.remarks,
  });

  factory SalaryPayrollModel.fromJson(Map<String, dynamic> json) {
    return SalaryPayrollModel(
      id: json['id'],
      employeeId: json['employee_id'],
      month: json['month'],
      year: json['year'],
      workingDays: json['working_days'],
      presentDays: json['present_days'],
      leaveDays: json['leave_days'],
      basicSalary: json['basic_salary'],
      attendanceDeduction: json['attendance_deduction'],
      advanceDeduction: json['advance_deduction'],
      netSalary: json['net_salary'],
      status: SalaryPaymentStatus.values
          .firstWhere((e) => e.name == json['status']),
      paymentDate: json['payment_date'] != null
          ? DateTime.parse(json['payment_date'])
          : null,
      paymentMode: json['payment_mode'] != null
          ? SalaryPaymentMode.values
              .firstWhere((e) => e.name == json['payment_mode'])
          : null,
      remarks: json['remarks'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'month': month,
      'year': year,
      'working_days': workingDays,
      'present_days': presentDays,
      'leave_days': leaveDays,
      'basic_salary': basicSalary,
      'attendance_deduction': attendanceDeduction,
      'advance_deduction': advanceDeduction,
      'net_salary': netSalary,
      'status': status.name,
      'payment_date': paymentDate?.toIso8601String(),
      'payment_mode': paymentMode?.name,
      'remarks': remarks,
    };
  }
}

final class SalaryAdvanceModel extends SalaryAdvance {
  const SalaryAdvanceModel({
    required super.id,
    required super.employeeId,
    required super.amount,
    required super.date,
    required super.reason,
    required super.isAdjusted,
  });

  factory SalaryAdvanceModel.fromJson(Map<String, dynamic> json) {
    return SalaryAdvanceModel(
      id: json['id'],
      employeeId: json['employee_id'],
      amount: json['amount'],
      date: DateTime.parse(json['date']),
      reason: json['reason'],
      isAdjusted: json['is_adjusted'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'employee_id': employeeId,
      'amount': amount,
      'date': date.toIso8601String(),
      'reason': reason,
      'is_adjusted': isAdjusted,
    };
  }
}
