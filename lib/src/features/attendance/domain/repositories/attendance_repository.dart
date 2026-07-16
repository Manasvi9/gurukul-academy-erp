import '../../../../core/models/result.dart';
import '../entities/attendance_record.dart';

abstract interface class AttendanceRepository {
  Future<Result<List<AttendanceRecord>>> classRoster({
    required String academicYearId,
    required String classId,
    required String sectionId,
  });

  Future<Result<void>> saveDailyAttendance({
    required String academicYearId,
    required String classId,
    required String sectionId,
    required DateTime date,
    required List<AttendanceRecord> records,
  });

  Future<Result<List<AttendanceRecord>>> studentHistory(String studentId);
}
