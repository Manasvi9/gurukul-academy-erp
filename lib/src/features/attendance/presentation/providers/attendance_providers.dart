import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../app/bootstrap/app_bootstrap.dart';
import '../../data/datasources/attendance_remote_datasource.dart';
import '../../data/repositories/attendance_repository_impl.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/repositories/attendance_repository.dart';

final attendanceRemoteDataSourceProvider =
    Provider<AttendanceRemoteDataSource>((ref) {
  return SupabaseAttendanceRemoteDataSource(ref.watch(supabaseClientProvider));
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  return AttendanceRepositoryImpl(
    ref.watch(attendanceRemoteDataSourceProvider),
  );
});

final class AttendanceRosterRequest {
  const AttendanceRosterRequest({
    required this.academicYearId,
    required this.classId,
    required this.sectionId,
  });

  final String academicYearId;
  final String classId;
  final String sectionId;

  @override
  bool operator ==(Object other) {
    return other is AttendanceRosterRequest &&
        other.academicYearId == academicYearId &&
        other.classId == classId &&
        other.sectionId == sectionId;
  }

  @override
  int get hashCode => Object.hash(academicYearId, classId, sectionId);
}

final attendanceRosterProvider =
    FutureProvider.family<List<AttendanceRecord>, AttendanceRosterRequest>((
  ref,
  request,
) async {
  final result = await ref.watch(attendanceRepositoryProvider).classRoster(
        academicYearId: request.academicYearId,
        classId: request.classId,
        sectionId: request.sectionId,
      );
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final studentAttendanceHistoryProvider =
    FutureProvider.family<List<AttendanceRecord>, String>(
        (ref, studentId) async {
  final result =
      await ref.watch(attendanceRepositoryProvider).studentHistory(studentId);
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final attendanceSaveControllerProvider = StateNotifierProvider.autoDispose<
    AttendanceSaveController, AsyncValue<void>>((ref) {
  return AttendanceSaveController(ref.watch(attendanceRepositoryProvider));
});

final class AttendanceSaveController extends StateNotifier<AsyncValue<void>> {
  AttendanceSaveController(this._repository)
      : super(const AsyncValue.data(null));

  final AttendanceRepository _repository;

  Future<bool> save({
    required String academicYearId,
    required String classId,
    required String sectionId,
    required DateTime date,
    required List<AttendanceRecord> records,
  }) async {
    state = const AsyncValue.loading();
    final result = await _repository.saveDailyAttendance(
      academicYearId: academicYearId,
      classId: classId,
      sectionId: sectionId,
      date: date,
      records: records,
    );
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
    );
  }
}
