import '../../domain/entities/student_detail.dart';
import '../../domain/entities/student_gender.dart';

final class StudentDetailModel extends StudentDetail {
  const StudentDetailModel({
    required super.id,
    required super.srNumber,
    required super.admissionDate,
    required super.name,
    required super.gender,
    required super.dateOfBirth,
    required super.fatherName,
    required super.motherName,
    required super.parentMobileNumber,
    required super.academicYear,
    required super.academicYearId,
    required super.className,
    required super.classId,
    required super.sectionName,
    required super.sectionId,
    required super.rollNumber,
    required super.feeDue,
    required super.attendancePercentage,
    required super.usesTransport,
    required super.villageName,
    required super.villageId,
    required super.transportFee,
    required super.isArchived,
  });

  factory StudentDetailModel.fromJson(Map<String, Object?> json) {
    return StudentDetailModel(
      id: json['id'] as String,
      srNumber: json['sr_number'] as String,
      admissionDate: DateTime.parse(json['admission_date'] as String),
      name: json['student_name'] as String,
      gender: StudentGender.fromValue(json['gender'] as String),
      dateOfBirth: DateTime.parse(json['date_of_birth'] as String),
      fatherName: json['father_name'] as String,
      motherName: json['mother_name'] as String,
      parentMobileNumber: json['parent_mobile_number'] as String,
      academicYear: json['academic_year'] as String? ?? '',
      academicYearId: json['academic_year_id'] as String,
      className: json['class_name'] as String? ?? '',
      classId: json['class_id'] as String,
      sectionName: json['section_name'] as String? ?? '',
      sectionId: json['section_id'] as String,
      rollNumber: json['roll_number'] as int?,
      feeDue: json['fee_due'] as num? ?? 0,
      attendancePercentage: json['attendance_percentage'] as num?,
      usesTransport: json['uses_transport'] as bool? ?? false,
      villageName: json['village_name'] as String?,
      villageId: json['village_id'] as String?,
      transportFee: json['transport_fee'] as num? ?? 0,
      isArchived: json['is_archived'] as bool? ?? false,
    );
  }
}
