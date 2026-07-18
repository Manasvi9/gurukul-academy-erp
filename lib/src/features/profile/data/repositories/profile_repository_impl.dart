import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

final class SupabaseProfileRepository implements ProfileRepository {
  SupabaseProfileRepository(this._client);
  final SupabaseClient _client;

  @override
  Future<UserProfile> getProfile(String userId) async {
    final response = await _client
        .from('staff_auth_profiles')
        .select('id, role, display_name, email, avatar_url')
        .eq('id', userId)
        .single();
    
    return UserProfile(
      id: response['id'] as String,
      role: response['role'] as String,
      name: response['display_name'] as String,
      email: response['email'] as String,
      avatarUrl: response['avatar_url'] as String?,
    );
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? avatarUrl,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['display_name'] = name;
    if (avatarUrl != null) updates['avatar_url'] = avatarUrl;
    
    await _client.from('staff_auth_profiles').update(updates).eq('id', userId);
  }
}
