import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../app/bootstrap/app_bootstrap.dart';
import '../../data/repositories/academic_structure_repository.dart';
import '../../domain/entities/academic_class.dart';
import '../../domain/entities/academic_section.dart';
import '../../domain/entities/academic_subject.dart';

final academicStructureRepositoryProvider =
    Provider<AcademicStructureRepository>(
  (ref) => AcademicStructureRepository(ref.watch(supabaseClientProvider)),
);

final classSearchProvider = StateProvider<String>((ref) => '');
final sectionClassFilterProvider = StateProvider<String?>((ref) => null);
final subjectSearchProvider = StateProvider<String>((ref) => '');

final academicClassesProvider = FutureProvider<List<AcademicClass>>((ref) {
  return ref.watch(academicStructureRepositoryProvider).classes(
        ref.watch(classSearchProvider),
      );
});

final activeAcademicClassesProvider =
    FutureProvider<List<AcademicClass>>((ref) {
  return ref.watch(academicStructureRepositoryProvider).activeClasses();
});

final academicSectionsProvider = FutureProvider<List<AcademicSection>>((ref) {
  return ref.watch(academicStructureRepositoryProvider).sections(
        ref.watch(sectionClassFilterProvider),
      );
});

final academicSubjectsProvider = FutureProvider<List<AcademicSubject>>((ref) {
  return ref.watch(academicStructureRepositoryProvider).subjects(
        ref.watch(subjectSearchProvider),
      );
});
