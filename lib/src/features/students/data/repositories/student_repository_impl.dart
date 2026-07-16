import '../../../../core/models/result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../domain/entities/academic_year.dart';
import '../../domain/entities/class_fee_structure.dart';
import '../../domain/entities/class_section.dart';
import '../../domain/entities/school_class.dart';
import '../../domain/entities/student_detail.dart';
import '../../domain/entities/student_form_data.dart';
import '../../domain/entities/student_summary.dart';
import '../../domain/entities/transport_village.dart';
import '../../domain/repositories/student_repository.dart';
import '../datasources/student_remote_datasource.dart';

final class StudentRepositoryImpl extends BaseRepository
    implements StudentRepository {
  const StudentRepositoryImpl(this._remoteDataSource);

  final StudentRemoteDataSource _remoteDataSource;

  @override
  Future<Result<List<StudentSummary>>> searchStudents(String query) {
    return guard(() => _remoteDataSource.searchStudents(query));
  }

  @override
  Future<Result<List<StudentSummary>>> recentlyViewedStudents() {
    return guard(_remoteDataSource.recentlyViewedStudents);
  }

  @override
  Future<Result<void>> markRecentlyViewed(String studentId) {
    return guard(() => _remoteDataSource.markRecentlyViewed(studentId));
  }

  @override
  Future<Result<List<AcademicYear>>> academicYears() {
    return guard(_remoteDataSource.academicYears);
  }

  @override
  Future<Result<List<SchoolClass>>> classes(String academicYearId) {
    return guard(() => _remoteDataSource.classes(academicYearId));
  }

  @override
  Future<Result<List<ClassSection>>> sections(String classId) {
    return guard(() => _remoteDataSource.sections(classId));
  }

  @override
  Future<Result<List<StudentSummary>>> studentsBySection({
    required String academicYearId,
    required String classId,
    required String sectionId,
  }) {
    return guard(
      () => _remoteDataSource.studentsBySection(
        academicYearId: academicYearId,
        classId: classId,
        sectionId: sectionId,
      ),
    );
  }

  @override
  Future<Result<StudentDetail>> studentDetails(String studentId) {
    return guard(() => _remoteDataSource.studentDetails(studentId));
  }

  @override
  Future<Result<String>> createStudent(StudentFormData data) {
    return guard(() => _remoteDataSource.createStudent(data));
  }

  @override
  Future<Result<void>> updateStudent({
    required String studentId,
    required StudentFormData data,
  }) {
    return guard(
      () => _remoteDataSource.updateStudent(
        studentId: studentId,
        data: data,
      ),
    );
  }

  @override
  Future<Result<void>> archiveStudent(String studentId) {
    return guard(() => _remoteDataSource.archiveStudent(studentId));
  }

  @override
  Future<Result<ClassFeeStructure>> feeStructure({
    required String academicYearId,
    required String classId,
  }) {
    return guard(
      () => _remoteDataSource.feeStructure(
        academicYearId: academicYearId,
        classId: classId,
      ),
    );
  }

  @override
  Future<Result<List<TransportVillage>>> transportVillages() {
    return guard(_remoteDataSource.transportVillages);
  }
}
