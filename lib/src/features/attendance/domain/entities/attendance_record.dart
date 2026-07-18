import 'attendance_status.dart';

class AttendanceRecord {
  const AttendanceRecord({
    required this.studentId,
    required this.studentName,
    required this.srNumber,
    required this.status,
    required this.note,
  });

  final String studentId;
  final String studentName;
  final String srNumber;
  final AttendanceStatus status;
  final String note;
}
