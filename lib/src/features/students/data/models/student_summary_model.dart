import '../../domain/entities/student_summary.dart';

final class StudentSummaryModel extends StudentSummary {
  const StudentSummaryModel({
    required super.id,
    required super.rollNumber,
    required super.name,
    required super.srNumber,
    required super.feeDue,
    required super.attendancePercentage,
    required super.className,
    required super.sectionName,
  });

  factory StudentSummaryModel.fromJson(Map<String, Object?> json) {
    return StudentSummaryModel(
      id: json['id'] as String,
      rollNumber: json['roll_number'] as int?,
      name: json['student_name'] as String,
      srNumber: json['sr_number'] as String,
      feeDue: json['fee_due'] as num? ?? 0,
      attendancePercentage: json['attendance_percentage'] as num?,
      className: json['class_name'] as String? ?? '',
      sectionName: json['section_name'] as String? ?? '',
    );
  }
}
