import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:gurukul_academy_erp/src/app/bootstrap/app_bootstrap.dart';
import 'package:gurukul_academy_erp/src/features/authentication/domain/entities/auth_role.dart';
import 'package:gurukul_academy_erp/src/features/authentication/presentation/providers/auth_providers.dart';
import 'package:gurukul_academy_erp/src/features/timetable/data/timetable_repository_impl.dart';
import 'package:gurukul_academy_erp/src/features/timetable/domain/entities/timetable_entry.dart';
import 'package:gurukul_academy_erp/src/features/timetable/domain/repositories/timetable_repository.dart';

final timetableRepositoryProvider = Provider<TimetableRepository>((ref) {
  final state = ref.watch(authControllerProvider);
  final custom = state.user?.role == AuthRole.parent ||
          state.user?.role == AuthRole.student
      ? state.session?.accessToken
      : null;
  return SupabaseTimetableRepository(
    ref.watch(supabaseClientProvider),
    customAccessToken: custom,
  );
});

class StringNotifier extends Notifier<String?> {
  @override
  String? build() => null;
  void set(String? value) => state = value;
}

final timetableClassFilterProvider = NotifierProvider<StringNotifier, String?>(StringNotifier.new);
final timetableSectionFilterProvider = NotifierProvider<StringNotifier, String?>(StringNotifier.new);
final timetableTeacherFilterProvider = NotifierProvider<StringNotifier, String?>(StringNotifier.new);

final timetableEntriesProvider =
    FutureProvider.autoDispose<List<TimetableEntry>>((ref) async {
  final authState = ref.watch(authControllerProvider);
  final role = authState.user?.role;
  final userId = authState.user?.id;

  String? teacherId;
  if (role == AuthRole.teacher) {
    teacherId = userId;
  } else {
    teacherId = ref.watch(timetableTeacherFilterProvider);
  }

  return ref.watch(timetableRepositoryProvider).list(
        classId: ref.watch(timetableClassFilterProvider),
        sectionId: ref.watch(timetableSectionFilterProvider),
        teacherId: teacherId,
      );
});

final timetableTeachersProvider =
    FutureProvider.autoDispose<List<TimetableTeacher>>((ref) {
  return ref.watch(timetableRepositoryProvider).teachers();
});
