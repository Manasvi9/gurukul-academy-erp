import 'package:supabase_flutter/supabase_flutter.dart';

import '../../domain/entities/student_form_data.dart';
import '../dto/student_form_dto.dart';
import '../models/academic_year_model.dart';
import '../models/class_fee_structure_model.dart';
import '../models/class_section_model.dart';
import '../models/school_class_model.dart';
import '../models/student_detail_model.dart';
import '../models/student_summary_model.dart';
import '../models/transport_village_model.dart';

abstract interface class StudentRemoteDataSource {
  Future<List<StudentSummaryModel>> searchStudents(String query);

  Future<List<StudentSummaryModel>> recentlyViewedStudents();

  Future<void> markRecentlyViewed(String studentId);

  Future<List<AcademicYearModel>> academicYears();

  Future<List<SchoolClassModel>> classes(String academicYearId);

  Future<List<ClassSectionModel>> sections(String classId);

  Future<List<StudentSummaryModel>> studentsBySection({
    required String academicYearId,
    required String classId,
    required String sectionId,
  });

  Future<StudentDetailModel> studentDetails(String studentId);

  Future<String> createStudent(StudentFormData data);

  Future<void> updateStudent({
    required String studentId,
    required StudentFormData data,
  });

  Future<void> archiveStudent(String studentId);

  Future<ClassFeeStructureModel> feeStructure({
    required String academicYearId,
    required String classId,
  });

  Future<List<TransportVillageModel>> transportVillages();
}

final class SupabaseStudentRemoteDataSource implements StudentRemoteDataSource {
  SupabaseStudentRemoteDataSource(
    this._client, {
    String? customAccessToken,
  }) : _customAccessToken = customAccessToken;

  final SupabaseClient _client;
  final String? _customAccessToken;

  bool get _usesCustomAuth => _customAccessToken != null;

  @override
  Future<List<StudentSummaryModel>> searchStudents(String query) async {
    if (_usesCustomAuth) {
      final data = await _invokeCustom<List<dynamic>>(
        action: 'search',
        body: {'search_query': query.trim()},
      );
      return data
          .cast<Map<String, Object?>>()
          .map(StudentSummaryModel.fromJson)
          .toList();
    }

    final response = await _client.rpc<List<dynamic>>(
      'search_students',
      params: {'search_query': query.trim()},
    );
    return response
        .cast<Map<String, Object?>>()
        .map(StudentSummaryModel.fromJson)
        .toList();
  }

  @override
  Future<List<StudentSummaryModel>> recentlyViewedStudents() async {
    if (_usesCustomAuth) {
      final data = await _invokeCustom<List<dynamic>>(
        action: 'recently_viewed',
      );
      return data
          .cast<Map<String, Object?>>()
          .map(StudentSummaryModel.fromJson)
          .toList();
    }

    final response = await _client
        .from('student_recently_viewed_details')
        .select()
        .order('viewed_at', ascending: false)
        .limit(10);
    return response
        .cast<Map<String, Object?>>()
        .map(StudentSummaryModel.fromJson)
        .toList();
  }

  @override
  Future<void> markRecentlyViewed(String studentId) async {
    if (_usesCustomAuth) {
      await _invokeCustom<Map<String, Object?>>(
        action: 'mark_recently_viewed',
        body: {'student_id': studentId},
      );
      return;
    }

    await _client.rpc<void>(
      'mark_student_recently_viewed',
      params: {'target_student_id': studentId},
    );
  }

  @override
  Future<List<AcademicYearModel>> academicYears() async {
    final response = await _client
        .from('academic_years')
        .select('id, name, starts_on, ends_on, is_active')
        .eq('is_active', true)
        .order('starts_on', ascending: false);
    return response
        .cast<Map<String, Object?>>()
        .map(AcademicYearModel.fromJson)
        .toList();
  }

  @override
  Future<List<SchoolClassModel>> classes(String academicYearId) async {
    final response = await _client
        .from('school_classes')
        .select('id, name, display_order')
        .eq('is_active', true)
        .order('display_order');
    return response
        .cast<Map<String, Object?>>()
        .map(SchoolClassModel.fromJson)
        .toList();
  }

  @override
  Future<List<ClassSectionModel>> sections(String classId) async {
    final response = await _client
        .from('class_sections')
        .select('id, class_id, name, display_order')
        .eq('class_id', classId)
        .eq('is_active', true)
        .order('display_order');
    return response
        .cast<Map<String, Object?>>()
        .map(ClassSectionModel.fromJson)
        .toList();
  }

  @override
  Future<List<StudentSummaryModel>> studentsBySection({
    required String academicYearId,
    required String classId,
    required String sectionId,
  }) async {
    if (_usesCustomAuth) {
      final data = await _invokeCustom<List<dynamic>>(
        action: 'list_by_section',
        body: {
          'academic_year_id': academicYearId,
          'class_id': classId,
          'section_id': sectionId,
        },
      );
      return data
          .cast<Map<String, Object?>>()
          .map(StudentSummaryModel.fromJson)
          .toList();
    }

    final response = await _client
        .from('student_list_details')
        .select()
        .eq('academic_year_id', academicYearId)
        .eq('class_id', classId)
        .eq('section_id', sectionId)
        .eq('is_archived', false)
        .order('roll_number', ascending: true);
    return response
        .cast<Map<String, Object?>>()
        .map(StudentSummaryModel.fromJson)
        .toList();
  }

  @override
  Future<StudentDetailModel> studentDetails(String studentId) async {
    if (_usesCustomAuth) {
      final data = await _invokeCustom<Map<String, Object?>>(
        action: 'details',
        body: {'student_id': studentId},
      );
      return StudentDetailModel.fromJson(data);
    }

    final response = await _client
        .from('student_profile_details')
        .select()
        .eq('id', studentId)
        .single();
    return StudentDetailModel.fromJson(response);
  }

  @override
  Future<String> createStudent(StudentFormData data) async {
    if (_usesCustomAuth) {
      throw AuthException('You do not have permission to create students.');
    }

    final response = await _client.rpc<String>(
      'create_student',
      params: StudentFormDto.fromEntity(data).body,
    );
    return response;
  }

  @override
  Future<void> updateStudent({
    required String studentId,
    required StudentFormData data,
  }) async {
    if (_usesCustomAuth) {
      throw AuthException('You do not have permission to update students.');
    }

    await _client.rpc<void>(
      'update_student',
      params: {
        'target_student_id': studentId,
        'p_sr_number': data.srNumber.trim(),
        'p_admission_date': _dateOnly(data.admissionDate),
        'p_student_name': data.name.trim(),
        'p_gender': data.gender.value,
        'p_date_of_birth': _dateOnly(data.dateOfBirth),
        'p_father_name': data.fatherName.trim(),
        'p_mother_name': data.motherName.trim(),
        'p_parent_mobile_number': data.parentMobileNumber.trim(),
        'p_academic_year_id': data.academicYearId,
        'p_class_id': data.classId,
        'p_section_id': data.sectionId,
        'p_scholarship_discount': data.scholarshipDiscount,
        'p_uses_transport': data.usesTransport,
        'p_village_id': data.villageId,
      },
    );
  }

  @override
  Future<void> archiveStudent(String studentId) async {
    if (_usesCustomAuth) {
      throw AuthException('You do not have permission to archive students.');
    }

    await _client.rpc<void>(
      'archive_student',
      params: {'target_student_id': studentId},
    );
  }

  @override
  Future<ClassFeeStructureModel> feeStructure({
    required String academicYearId,
    required String classId,
  }) async {
    final response = await _client
        .from('class_fee_structures')
        .select(
          'id, academic_year_id, class_id, tuition_fee, admission_fee, exam_fee',
        )
        .eq('academic_year_id', academicYearId)
        .eq('class_id', classId)
        .eq('is_active', true)
        .single();
    return ClassFeeStructureModel.fromJson(response);
  }

  @override
  Future<List<TransportVillageModel>> transportVillages() async {
    final response = await _client
        .from('transport_villages')
        .select('id, name, transport_fee, is_active')
        .eq('is_active', true)
        .order('name');
    return response
        .cast<Map<String, Object?>>()
        .map(TransportVillageModel.fromJson)
        .toList();
  }

  Future<T> _invokeCustom<T>({
    required String action,
    Map<String, Object?> body = const {},
  }) async {
    final response = await _client.functions.invoke(
      'student-access',
      headers: {'Authorization': 'Bearer $_customAccessToken'},
      body: {'action': action, ...body},
    );

    if (response.status < 200 || response.status >= 300) {
      final data = response.data;
      if (data is Map && data['error'] is String) {
        throw AuthException(data['error'] as String);
      }
      throw AuthException('Student request failed.');
    }
    return response.data as T;
  }

  String _dateOnly(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
