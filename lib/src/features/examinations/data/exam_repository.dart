import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/exam.dart';
import '../domain/entities/exam_mark.dart';
import '../domain/repositories/exam_repository.dart';

final class SupabaseExamRepository implements ExamRepository {
  SupabaseExamRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<List<Exam>> list() async {
    final rows = await _client
        .from('exams')
        .select()
        .eq('is_archived', false)
        .order('exam_date', ascending: false);
    return rows
        .cast<Map<String, Object?>>()
        .map(
          (r) => Exam(
            id: r['id'] as String,
            name: r['name'] as String,
            type: r['type'] as String,
            date: DateTime.parse(r['exam_date'] as String),
            status: r['status'] as String,
          ),
        )
        .toList();
  }

  @override
  Future<void> createExam(Map<String, Object?> values) =>
      _client.from('exams').insert(values);

  @override
  Future<void> updateExam(String id, Map<String, Object?> values) =>
      _client.from('exams').update(values).eq('id', id);

  @override
  Future<void> deleteExam(String id) =>
      _client.from('exams').delete().eq('id', id);

  @override
  Future<void> archive(String id) => _client
      .from('exams')
      .update({'is_archived': true, 'status': 'archived'}).eq('id', id);
  @override
  Future<void> saveMarks({
    required String examSubjectId,
    required List<ExamMark> marks,
    required bool isFinal,
  }) async {
    await _client.from('exam_marks').upsert(
          marks
              .map(
                (e) => {
                  'exam_subject_id': examSubjectId,
                  'student_id': e.studentId,
                  'marks': e.marks,
                  'is_final': isFinal,
                  'updated_by': _client.auth.currentUser!.id,
                },
              )
              .toList(),
          onConflict: 'exam_subject_id,student_id',
        );
  }
}
