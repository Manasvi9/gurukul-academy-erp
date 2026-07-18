import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../../../app/bootstrap/app_bootstrap.dart';
import '../data/notification_repository.dart';
import '../domain/entities/app_notification.dart';

final notificationRepositoryProvider = Provider(
  (ref) => NotificationRepository(ref.watch(supabaseClientProvider)),
);
final notificationSearchProvider = StateProvider<String>((ref) => '');
final notificationTypeFilterProvider = StateProvider<String?>((ref) => null);
final notificationsProvider = FutureProvider<List<AppNotification>>(
  (ref) => ref.watch(notificationRepositoryProvider).list(
        ref.watch(notificationSearchProvider),
        ref.watch(notificationTypeFilterProvider),
      ),
);
