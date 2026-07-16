import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_status.dart';

final class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.studentId,
    required super.studentName,
    required super.srNumber,
    required super.status,
    required super.note,
  });

  factory AttendanceRecordModel.fromStudentJson(Map<String, Object?> json) {
    return AttendanceRecordModel(
      studentId: json['id'] as String,
      studentName: json['student_name'] as String,
      srNumber: json['sr_number'] as String,
      status: AttendanceStatus.present,
      note: '',
    );
  }

  factory AttendanceRecordModel.fromHistoryJson(Map<String, Object?> json) {
    return AttendanceRecordModel(
      studentId: json['student_id'] as String,
      studentName: json['student_name'] as String,
      srNumber: json['sr_number'] as String,
      status: AttendanceStatus.values.firstWhere(
        (status) => status.value == json['status'],
      ),
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, Object?> toJson() {
    return {
      'student_id': studentId,
      'status': status.value,
      'note': note,
    };
  }
}
