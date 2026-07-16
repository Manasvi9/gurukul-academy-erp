import 'student_gender.dart';

final class StudentFormData {
  const StudentFormData({
    required this.srNumber,
    required this.admissionDate,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.fatherName,
    required this.motherName,
    required this.parentMobileNumber,
    required this.academicYearId,
    required this.classId,
    required this.sectionId,
    required this.scholarshipDiscount,
    required this.usesTransport,
    required this.villageId,
  });

  final String srNumber;
  final DateTime admissionDate;
  final String name;
  final StudentGender gender;
  final DateTime dateOfBirth;
  final String fatherName;
  final String motherName;
  final String parentMobileNumber;
  final String academicYearId;
  final String classId;
  final String sectionId;
  final num scholarshipDiscount;
  final bool usesTransport;
  final String? villageId;
}
