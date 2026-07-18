import '../entities/user_profile.dart';

abstract interface class ProfileRepository {
  Future<UserProfile> getProfile(String userId);
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? avatarUrl,
  });
}
