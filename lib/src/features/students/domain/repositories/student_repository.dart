import '../../../../core/models/result.dart';
import '../entities/academic_year.dart';
import '../entities/class_fee_structure.dart';
import '../entities/class_section.dart';
import '../entities/school_class.dart';
import '../entities/student_detail.dart';
import '../entities/student_form_data.dart';
import '../entities/student_summary.dart';
import '../entities/transport_village.dart';

abstract interface class StudentRepository {
  Future<Result<List<StudentSummary>>> searchStudents(String query);

  Future<Result<List<StudentSummary>>> recentlyViewedStudents();

  Future<Result<void>> markRecentlyViewed(String studentId);

  Future<Result<List<AcademicYear>>> academicYears();

  Future<Result<List<SchoolClass>>> classes(String academicYearId);

  Future<Result<List<ClassSection>>> sections(String classId);

  Future<Result<List<StudentSummary>>> studentsBySection({
    required String academicYearId,
    required String classId,
    required String sectionId,
  });

  Future<Result<StudentDetail>> studentDetails(String studentId);

  Future<Result<String>> createStudent(StudentFormData data);

  Future<Result<void>> updateStudent({
    required String studentId,
    required StudentFormData data,
  });

  Future<Result<void>> archiveStudent(String studentId);

  Future<Result<ClassFeeStructure>> feeStructure({
    required String academicYearId,
    required String classId,
  });

  Future<Result<List<TransportVillage>>> transportVillages();
}
