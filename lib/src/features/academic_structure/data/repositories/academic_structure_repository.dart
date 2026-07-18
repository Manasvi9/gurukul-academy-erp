import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/academic_class.dart';
import '../../domain/entities/academic_section.dart';
import '../../domain/entities/academic_subject.dart';

final class AcademicStructureRepository {
  AcademicStructureRepository(this._client);

  final SupabaseClient _client;

  Future<List<AcademicClass>> classes(String query) async {
    var request = _client
        .from('school_classes')
        .select('id, name, display_order, is_active')
        .eq('is_archived', false);
    if (query.trim().isNotEmpty) {
      request = request.ilike('name', '%${query.trim()}%');
    }
    final rows = await request.order('display_order').order('name');
    return rows.cast<Map<String, Object?>>().map(_classFromRow).toList();
  }

  Future<List<AcademicClass>> activeClasses() async {
    final rows = await _client
        .from('school_classes')
        .select('id, name, display_order, is_active')
        .eq('is_archived', false)
        .eq('is_active', true)
        .order('display_order')
        .order('name');
    return rows.cast<Map<String, Object?>>().map(_classFromRow).toList();
  }

  Future<void> saveClass({
    String? id,
    required String name,
    required int displayOrder,
    required bool isActive,
  }) async {
    final values = <String, Object?>{
      'name': name.trim(),
      'display_order': displayOrder,
      'is_active': isActive,
    };
    if (id == null) {
      await _client.from('school_classes').insert(values);
    } else {
      await _client.from('school_classes').update(values).eq('id', id);
    }
  }

  Future<void> archiveClass(String id) {
    return _client
        .rpc<void>('archive_academic_class', params: {'target_id': id});
  }

  Future<List<AcademicSection>> sections(String? classId) async {
    var request = _client.from('academic_sections').select();
    if (classId != null) {
      request = request.eq('class_id', classId);
    }
    final rows =
        await request.order('class_name').order('display_order').order('name');
    return rows
        .cast<Map<String, Object?>>()
        .map(
          (row) => AcademicSection(
            id: row['id'] as String,
            classId: row['class_id'] as String,
            className: row['class_name'] as String,
            name: row['name'] as String,
            capacity: row['capacity'] as int?,
            isActive: row['is_active'] as bool,
          ),
        )
        .toList();
  }

  Future<void> saveSection({
    String? id,
    required String classId,
    required String name,
    int? capacity,
    required bool isActive,
  }) async {
    final values = <String, Object?>{
      'class_id': classId,
      'name': name.trim(),
      'capacity': capacity,
      'is_active': isActive,
    };
    if (id == null) {
      await _client.from('class_sections').insert(values);
    } else {
      await _client.from('class_sections').update(values).eq('id', id);
    }
  }

  Future<void> archiveSection(String id) {
    return _client
        .rpc<void>('archive_academic_section', params: {'target_id': id});
  }

  Future<List<AcademicSubject>> subjects(String query) async {
    var request = _client
        .from('subjects')
        .select(
          'id, name, code, display_order, is_active, class_subjects(class_id)',
        )
        .eq('is_archived', false);
    if (query.trim().isNotEmpty) {
      final term = query.trim();
      request = request.or('name.ilike.%$term%,code.ilike.%$term%');
    }
    final rows = await request.order('display_order').order('name');
    return rows
        .cast<Map<String, Object?>>()
        .map(
          (row) => AcademicSubject(
            id: row['id'] as String,
            name: row['name'] as String,
            code: row['code'] as String?,
            classIds: (row['class_subjects'] as List<dynamic>? ?? const [])
                .cast<Map<String, Object?>>()
                .map((item) => item['class_id'] as String)
                .toList(),
            displayOrder: row['display_order'] as int,
            isActive: row['is_active'] as bool,
          ),
        )
        .toList();
  }

  Future<void> saveSubject({
    String? id,
    required String name,
    String? code,
    required List<String> classIds,
    required int displayOrder,
    required bool isActive,
  }) async {
    await _client.rpc<String>(
      'save_subject',
      params: {
        'p_id': id,
        'p_name': name.trim(),
        'p_code': code?.trim() ?? '',
        'p_display_order': displayOrder,
        'p_is_active': isActive,
        'p_class_ids': classIds,
      },
    );
  }

  Future<void> archiveSubject(String id) {
    return _client.rpc<void>('archive_subject', params: {'target_id': id});
  }

  AcademicClass _classFromRow(Map<String, Object?> row) => AcademicClass(
        id: row['id'] as String,
        name: row['name'] as String,
        displayOrder: row['display_order'] as int,
        isActive: row['is_active'] as bool,
      );
}
