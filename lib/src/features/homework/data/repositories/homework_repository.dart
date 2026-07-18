import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/homework_item.dart';

final class HomeworkRepository {
  HomeworkRepository(this._client);

  final SupabaseClient _client;

  Future<List<HomeworkItem>> list() async {
    final rows = await _client
        .from('homework_details')
        .select()
        .order('due_date')
        .order('created_at', ascending: false);
    return rows.cast<Map<String, Object?>>().map(_fromRow).toList();
  }

  Future<String?> activeAcademicYearId() async {
    final row = await _client
        .from('academic_years')
        .select('id')
        .eq('is_active', true)
        .order('starts_on', ascending: false)
        .limit(1)
        .maybeSingle();
    return row?['id'] as String?;
  }

  Future<void> save({
    String? id,
    required String academicYearId,
    required String classId,
    required String sectionId,
    required String subjectId,
    required DateTime dueDate,
    required String description,
  }) async {
    final values = <String, Object?>{
      'academic_year_id': academicYearId,
      'class_id': classId,
      'section_id': sectionId,
      'subject_id': subjectId,
      'due_date': _dateOnly(dueDate),
      'description': description.trim(),
    };
    if (id == null) {
      await _client.from('homework').insert({
        ...values,
        'teacher_id': _client.auth.currentUser!.id,
      });
    } else {
      await _client.from('homework').update(values).eq('id', id);
    }
  }

  Future<void> delete(String id) =>
      _client.from('homework').update({'is_deleted': true}).eq('id', id);

  HomeworkItem _fromRow(Map<String, Object?> row) => HomeworkItem(
        id: row['id'] as String,
        academicYearId: row['academic_year_id'] as String,
        classId: row['class_id'] as String,
        className: row['class_name'] as String,
        sectionId: row['section_id'] as String,
        sectionName: row['section_name'] as String,
        subjectId: row['subject_id'] as String,
        subjectName: row['subject_name'] as String,
        dueDate: DateTime.parse(row['due_date'] as String),
        description: row['description'] as String,
      );

  String _dateOnly(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-'
      '${value.month.toString().padLeft(2, '0')}-'
      '${value.day.toString().padLeft(2, '0')}';
}
