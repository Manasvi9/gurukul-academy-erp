import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../app/bootstrap/app_bootstrap.dart';
import '../../data/repositories/teacher_repository.dart';
import '../../domain/entities/teacher.dart';

final teacherRepositoryProvider =
    Provider((ref) => TeacherRepository(ref.watch(supabaseClientProvider)));

final teacherSearchProvider = StateProvider<String>((ref) => '');

final teachersProvider = FutureProvider<List<Teacher>>((ref) {
  final repository = ref.watch(teacherRepositoryProvider);
  final search = ref.watch(teacherSearchProvider);

  return repository.list(search);
});