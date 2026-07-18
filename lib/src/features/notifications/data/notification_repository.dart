import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/entities/app_notification.dart';

final class NotificationRepository {
  NotificationRepository(this._client);
  final SupabaseClient _client;
  Future<List<AppNotification>> list(String query, String? type) async {
    var request =
        _client.from('notifications').select().eq('is_archived', false);
    if (query.trim().isNotEmpty) {
      request = request.or(
        'title.ilike.%${query.trim()}%,description.ilike.%${query.trim()}%',
      );
    }
    if (type != null) {
      request = request.eq('type', type);
    }
    final rows =
        await request.order('published_on', ascending: false).range(0, 49);
    return rows
        .cast<Map<String, Object?>>()
        .map(
          (row) => AppNotification(
            id: row['id'] as String,
            title: row['title'] as String,
            description: row['description'] as String,
            type: row['type'] as String,
            audience: row['audience'] as String,
            publishedOn: DateTime.parse(row['published_on'] as String),
            expiresOn: row['expires_on'] == null
                ? null
                : DateTime.parse(row['expires_on'] as String),
          ),
        )
        .toList();
  }

  Future<void> save({
    String? id,
    required String title,
    required String description,
    required String type,
    required String audience,
    required DateTime publishedOn,
    DateTime? expiresOn,
  }) async {
    final values = {
      'title': title.trim(),
      'description': description.trim(),
      'type': type,
      'audience': audience,
      'published_on': _date(publishedOn),
      'expires_on': expiresOn == null ? null : _date(expiresOn),
    };
    if (id == null) {
      await _client
          .from('notifications')
          .insert({...values, 'created_by': _client.auth.currentUser!.id});
    } else {
      await _client.from('notifications').update(values).eq('id', id);
    }
  }

  Future<void> archive(String id) =>
      _client.from('notifications').update({'is_archived': true}).eq('id', id);
  String _date(DateTime value) =>
      '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';
}
