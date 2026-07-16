import '../../../../core/models/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';
import '../datasources/attendance_remote_datasource.dart';

final class AttendanceRepositoryImpl extends BaseRepository
    implements AttendanceRepository {
  const AttendanceRepositoryImpl(this._remoteDataSource);

  final AttendanceRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<AttendanceRecord>>> classRoster({
    required String academicYearId,
    required String classId,
    required String sectionId,
  }) {
    return guard(
      () => _remoteDataSource.classRoster(
        academicYearId: academicYearId,
        classId: classId,
        sectionId: sectionId,
      ),
    );
  }

  @override
  Future<Result<void>> saveDailyAttendance({
    required String academicYearId,
    required String classId,
    required String sectionId,
    required DateTime date,
    required List<AttendanceRecord> records,
  }) {
    return guard(
      () => _remoteDataSource.saveDailyAttendance(
        academicYearId: academicYearId,
        classId: classId,
        sectionId: sectionId,
        date: date,
        records: records,
      ),
    );
  }

  @override
  Future<Result<List<AttendanceRecord>>> studentHistory(String studentId) {
    return guard(() => _remoteDataSource.studentHistory(studentId));
  }
}
