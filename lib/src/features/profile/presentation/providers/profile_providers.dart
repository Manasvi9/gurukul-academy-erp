import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../app/bootstrap/app_bootstrap.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/repositories/profile_repository_impl.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/profile_repository.dart';

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return SupabaseProfileRepository(ref.watch(supabaseClientProvider));
});

final profileProvider = FutureProvider<UserProfile>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final userId = authState.user?.id;
  if (userId == null) throw Exception('User not authenticated');

  return ref.watch(profileRepositoryProvider).getProfile(userId);
});
