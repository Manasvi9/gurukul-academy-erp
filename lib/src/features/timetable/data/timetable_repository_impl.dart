import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/timetable_entry.dart';
import '../domain/repositories/timetable_repository.dart';

final class SupabaseTimetableRepository implements TimetableRepository {
  SupabaseTimetableRepository(this._client, {this.customAccessToken}); final SupabaseClient _client; final String? customAccessToken;
  @override Future<List<TimetableEntry>> list({String? classId, String? sectionId}) async {
    List<dynamic> rows;
    if (customAccessToken != null) { final response = await _client.functions.invoke('timetable-access', headers: {'Authorization': 'Bearer $customAccessToken'}); if (response.status < 200 || response.status >= 300) throw AuthException('Unable to load timetable.'); rows = response.data as List<dynamic>; }
    else { var request = _client.from('timetable_entry_details').select(); if (classId != null) request = request.eq('class_id', classId); if (sectionId != null) request = request.eq('section_id', sectionId); rows = await request.order('day_of_week').order('start_time'); }
    return rows.cast<Map<String, Object?>>().map(_map).toList();
  }
  @override Future<List<TimetableTeacher>> teachers() async { final rows = await _client.rpc<List<dynamic>>('timetable_teacher_options'); return rows.cast<Map<String, Object?>>().map((row) => TimetableTeacher(row['id'] as String, row['display_name'] as String)).toList(); }
  @override Future<void> save(TimetableEntry entry) async { final values = {'class_id': entry.classId, 'section_id': entry.sectionId, 'subject_id': entry.subjectId, 'teacher_id': entry.teacherId, 'day_of_week': entry.dayOfWeek, 'start_time': entry.startTime, 'end_time': entry.endTime, 'room': entry.room}; if (entry.id.isEmpty) { await _client.from('timetable_entries').insert(values); } else { await _client.from('timetable_entries').update(values).eq('id', entry.id); } }
  @override Future<void> delete(String id) => _client.from('timetable_entries').delete().eq('id', id);
  TimetableEntry _map(Map<String, Object?> row) => TimetableEntry(id: row['id'] as String, classId: row['class_id'] as String, className: row['class_name'] as String, sectionId: row['section_id'] as String, sectionName: row['section_name'] as String, subjectId: row['subject_id'] as String, subjectName: row['subject_name'] as String, teacherId: row['teacher_id'] as String, teacherName: row['teacher_name'] as String, dayOfWeek: row['day_of_week'] as int, startTime: row['start_time'] as String, endTime: row['end_time'] as String, room: row['room'] as String?);
}
