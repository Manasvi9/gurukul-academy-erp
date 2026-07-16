import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/attendance_record.dart';
import '../models/attendance_record_model.dart';

abstract interface class AttendanceRemoteDataSource {
  Future<List<AttendanceRecordModel>> classRoster({
    required String academicYearId,
    required String classId,
    required String sectionId,
  });

  Future<void> saveDailyAttendance({
    required String academicYearId,
    required String classId,
    required String sectionId,
    required DateTime date,
    required List<AttendanceRecord> records,
  });

  Future<List<AttendanceRecordModel>> studentHistory(String studentId);
}

final class SupabaseAttendanceRemoteDataSource
    implements AttendanceRemoteDataSource {
  SupabaseAttendanceRemoteDataSource(this._client);

  final SupabaseClient _client;

  @override
  Future<List<AttendanceRecordModel>> classRoster({
    required String academicYearId,
    required String classId,
    required String sectionId,
  }) async {
    final response = await _client
        .from('student_list_details')
        .select('id, student_name, sr_number')
        .eq('academic_year_id', academicYearId)
        .eq('class_id', classId)
        .eq('section_id', sectionId)
        .eq('is_archived', false)
        .order('roll_number');
    return response
        .cast<Map<String, Object?>>()
        .map(AttendanceRecordModel.fromStudentJson)
        .toList();
  }

  @override
  Future<void> saveDailyAttendance({
    required String academicYearId,
    required String classId,
    required String sectionId,
    required DateTime date,
    required List<AttendanceRecord> records,
  }) async {
    await _client.rpc<void>(
      'save_daily_attendance',
      params: {
        'target_academic_year_id': academicYearId,
        'target_class_id': classId,
        'target_section_id': sectionId,
        'target_date': _dateOnly(date),
        'records': records
            .map(
              (record) => AttendanceRecordModel(
                studentId: record.studentId,
                studentName: record.studentName,
                srNumber: record.srNumber,
                status: record.status,
                note: record.note,
              ).toJson(),
            )
            .toList(),
      },
    );
  }

  @override
  Future<List<AttendanceRecordModel>> studentHistory(String studentId) async {
    final response = await _client
        .from('student_attendance_history')
        .select()
        .eq('student_id', studentId)
        .order('attendance_date', ascending: false);
    return response
        .cast<Map<String, Object?>>()
        .map(AttendanceRecordModel.fromHistoryJson)
        .toList();
  }

  String _dateOnly(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
