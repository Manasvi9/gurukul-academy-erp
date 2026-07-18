import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/teacher.dart';

final class TeacherRepository {
  TeacherRepository(this._client);
  final SupabaseClient _client;
  Future<List<Teacher>> list(String query) async {
    var request = _client.from('teachers').select().eq('is_archived', false);
    if (query.trim().isNotEmpty) {
      final term = query.trim();
      request = request.or('full_name.ilike.%$term%,employee_id.ilike.%$term%');
    }
    final rows = await request.order('full_name');
    return rows.cast<Map<String, Object?>>().map(_map).toList();
  }

  Future<void> save({
    String? id,
    required String employeeId,
    required String fullName,
    String? phone,
    String? email,
  }) async {
    final data = {
      'employee_id': employeeId.trim(),
      'full_name': fullName.trim(),
      'phone': phone?.trim(),
      'email': email?.trim(),
    };
    if (id == null) {
      await _client.from('teachers').insert(data);
    } else {
      await _client.from('teachers').update(data).eq('id', id);
    }
  }

  Future<void> archive(String id) =>
      _client.from('teachers').update({'is_archived': true}).eq('id', id);
  Teacher _map(Map<String, Object?> row) => Teacher(
        id: row['id'] as String,
        employeeId: row['employee_id'] as String,
        fullName: row['full_name'] as String,
        phone: row['phone'] as String?,
        email: row['email'] as String?,
        isArchived: row['is_archived'] as bool,
      );
}
