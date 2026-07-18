import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../../../app/bootstrap/app_bootstrap.dart';
import '../../../authentication/domain/entities/auth_role.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../../data/datasources/student_remote_datasource.dart';
import '../../data/repositories/student_repository_impl.dart';
import '../../domain/entities/academic_year.dart';
import '../../domain/entities/class_fee_structure.dart';
import '../../domain/entities/class_section.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/entities/student_detail.dart';
import '../../domain/entities/student_form_data.dart';
import '../../domain/entities/student_summary.dart';
import '../../domain/entities/transport_village.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/usecases/archive_student_usecase.dart';
import '../../domain/usecases/get_academic_years_usecase.dart';
import '../../domain/usecases/get_classes_usecase.dart';
import '../../domain/usecases/get_recently_viewed_students_usecase.dart';
import '../../domain/usecases/get_sections_usecase.dart';
import '../../domain/usecases/get_student_details_usecase.dart';
import '../../domain/usecases/get_student_fee_structure_usecase.dart';
import '../../domain/usecases/get_students_by_section_usecase.dart';
import '../../domain/usecases/get_transport_villages_usecase.dart';
import '../../domain/usecases/save_student_usecase.dart';
import '../../domain/usecases/search_students_usecase.dart';

final studentRemoteDataSourceProvider =
    Provider<StudentRemoteDataSource>((ref) {
  final authState = ref.watch(authControllerProvider);
  final role = authState.user?.role;
  final customAccessToken = role == AuthRole.parent || role == AuthRole.student
      ? authState.session?.accessToken
      : null;

  return SupabaseStudentRemoteDataSource(
    ref.watch(supabaseClientProvider),
    customAccessToken: customAccessToken,
  );
});

final studentRepositoryProvider = Provider<StudentRepository>((ref) {
  return StudentRepositoryImpl(ref.watch(studentRemoteDataSourceProvider));
});

final searchStudentsUseCaseProvider = Provider<SearchStudentsUseCase>((ref) {
  return SearchStudentsUseCase(ref.watch(studentRepositoryProvider));
});

final recentlyViewedStudentsUseCaseProvider =
    Provider<GetRecentlyViewedStudentsUseCase>((ref) {
  return GetRecentlyViewedStudentsUseCase(ref.watch(studentRepositoryProvider));
});

final academicYearsUseCaseProvider = Provider<GetAcademicYearsUseCase>((ref) {
  return GetAcademicYearsUseCase(ref.watch(studentRepositoryProvider));
});

final classesUseCaseProvider = Provider<GetClassesUseCase>((ref) {
  return GetClassesUseCase(ref.watch(studentRepositoryProvider));
});

final sectionsUseCaseProvider = Provider<GetSectionsUseCase>((ref) {
  return GetSectionsUseCase(ref.watch(studentRepositoryProvider));
});

final studentsBySectionUseCaseProvider =
    Provider<GetStudentsBySectionUseCase>((ref) {
  return GetStudentsBySectionUseCase(ref.watch(studentRepositoryProvider));
});

final studentDetailsUseCaseProvider = Provider<GetStudentDetailsUseCase>((ref) {
  return GetStudentDetailsUseCase(ref.watch(studentRepositoryProvider));
});

final saveStudentUseCaseProvider = Provider<SaveStudentUseCase>((ref) {
  return SaveStudentUseCase(ref.watch(studentRepositoryProvider));
});

final archiveStudentUseCaseProvider = Provider<ArchiveStudentUseCase>((ref) {
  return ArchiveStudentUseCase(ref.watch(studentRepositoryProvider));
});

final studentFeeStructureUseCaseProvider =
    Provider<GetStudentFeeStructureUseCase>((ref) {
  return GetStudentFeeStructureUseCase(ref.watch(studentRepositoryProvider));
});

final transportVillagesUseCaseProvider =
    Provider<GetTransportVillagesUseCase>((ref) {
  return GetTransportVillagesUseCase(ref.watch(studentRepositoryProvider));
});

final academicYearsProvider = FutureProvider<List<AcademicYear>>((ref) async {
  final result = await ref.watch(academicYearsUseCaseProvider)();
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final classesProvider = FutureProvider.family<List<SchoolClass>, String>(
    (ref, academicYearId) async {
  final result = await ref.watch(classesUseCaseProvider)(academicYearId);
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final sectionsProvider =
    FutureProvider.family<List<ClassSection>, String>((ref, classId) async {
  final result = await ref.watch(sectionsUseCaseProvider)(classId);
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final studentListProvider =
    FutureProvider.family<List<StudentSummary>, StudentListRequest>((
  ref,
  request,
) async {
  final result = await ref.watch(studentsBySectionUseCaseProvider)(
    academicYearId: request.academicYearId,
    classId: request.classId,
    sectionId: request.sectionId,
  );
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final studentDetailsProvider =
    FutureProvider.family<StudentDetail, String>((ref, studentId) async {
  final result = await ref.watch(studentDetailsUseCaseProvider)(studentId);
  await ref.watch(studentRepositoryProvider).markRecentlyViewed(studentId);
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final recentlyViewedStudentsProvider =
    FutureProvider<List<StudentSummary>>((ref) async {
  final result = await ref.watch(recentlyViewedStudentsUseCaseProvider)();
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final studentSearchControllerProvider = StateNotifierProvider.autoDispose<
    StudentSearchController, AsyncValue<List<StudentSummary>>>((ref) {
  return StudentSearchController(ref.watch(searchStudentsUseCaseProvider));
});

final feeStructureProvider =
    FutureProvider.family<ClassFeeStructure, FeeStructureRequest>((
  ref,
  request,
) async {
  final result = await ref.watch(studentFeeStructureUseCaseProvider)(
    academicYearId: request.academicYearId,
    classId: request.classId,
  );
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final transportVillagesProvider =
    FutureProvider<List<TransportVillage>>((ref) async {
  final result = await ref.watch(transportVillagesUseCaseProvider)();
  return result.when(
    success: (value) => value,
    failure: (failure) => throw failure.message,
  );
});

final saveStudentControllerProvider =
    StateNotifierProvider.autoDispose<SaveStudentController, AsyncValue<void>>((
  ref,
) {
  return SaveStudentController(ref.watch(saveStudentUseCaseProvider));
});

final archiveStudentControllerProvider = StateNotifierProvider.autoDispose<
    ArchiveStudentController, AsyncValue<void>>((
  ref,
) {
  return ArchiveStudentController(ref.watch(archiveStudentUseCaseProvider));
});

final class StudentListRequest {
  const StudentListRequest({
    required this.academicYearId,
    required this.classId,
    required this.sectionId,
  });

  final String academicYearId;
  final String classId;
  final String sectionId;

  @override
  bool operator ==(Object other) {
    return other is StudentListRequest &&
        other.academicYearId == academicYearId &&
        other.classId == classId &&
        other.sectionId == sectionId;
  }

  @override
  int get hashCode => Object.hash(academicYearId, classId, sectionId);
}

final class FeeStructureRequest {
  const FeeStructureRequest({
    required this.academicYearId,
    required this.classId,
  });

  final String academicYearId;
  final String classId;

  @override
  bool operator ==(Object other) {
    return other is FeeStructureRequest &&
        other.academicYearId == academicYearId &&
        other.classId == classId;
  }

  @override
  int get hashCode => Object.hash(academicYearId, classId);
}

final class StudentSearchController
    extends StateNotifier<AsyncValue<List<StudentSummary>>> {
  StudentSearchController(this._searchStudentsUseCase)
      : super(const AsyncValue.data([]));

  final SearchStudentsUseCase _searchStudentsUseCase;

  Future<void> search(String query) async {
    if (query.trim().isEmpty) {
      state = const AsyncValue.data([]);
      return;
    }

    state = const AsyncValue.loading();
    final result = await _searchStudentsUseCase(query);
    state = result.when(
      success: AsyncValue.data,
      failure: (failure) => AsyncValue.error(
        failure.message,
        StackTrace.current,
      ),
    );
  }
}

final class SaveStudentController extends StateNotifier<AsyncValue<void>> {
  SaveStudentController(this._saveStudentUseCase)
      : super(const AsyncValue.data(null));

  final SaveStudentUseCase _saveStudentUseCase;

  Future<String?> create(StudentFormData data) async {
    state = const AsyncValue.loading();
    final result = await _saveStudentUseCase.create(data);
    return result.when(
      success: (studentId) {
        state = const AsyncValue.data(null);
        return studentId;
      },
      failure: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
    );
  }

  Future<bool> update({
    required String studentId,
    required StudentFormData data,
  }) async {
    state = const AsyncValue.loading();
    final result = await _saveStudentUseCase.update(
      studentId: studentId,
      data: data,
    );
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
    );
  }
}

final class ArchiveStudentController extends StateNotifier<AsyncValue<void>> {
  ArchiveStudentController(this._archiveStudentUseCase)
      : super(const AsyncValue.data(null));

  final ArchiveStudentUseCase _archiveStudentUseCase;

  Future<bool> archive(String studentId) async {
    state = const AsyncValue.loading();
    final result = await _archiveStudentUseCase(studentId);
    return result.when(
      success: (_) {
        state = const AsyncValue.data(null);
        return true;
      },
      failure: (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
    );
  }
}
