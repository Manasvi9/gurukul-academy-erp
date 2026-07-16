import 'student_gender.dart';

final class StudentDetail {
  const StudentDetail({
    required this.id,
    required this.srNumber,
    required this.admissionDate,
    required this.name,
    required this.gender,
    required this.dateOfBirth,
    required this.fatherName,
    required this.motherName,
    required this.parentMobileNumber,
    required this.academicYear,
    required this.academicYearId,
    required this.className,
    required this.classId,
    required this.sectionName,
    required this.sectionId,
    required this.rollNumber,
    required this.feeDue,
    required this.attendancePercentage,
    required this.usesTransport,
    required this.villageName,
    required this.villageId,
    required this.transportFee,
    required this.isArchived,
  });

  final String id;
  final String srNumber;
  final DateTime admissionDate;
  final String name;
  final StudentGender gender;
  final DateTime dateOfBirth;
  final String fatherName;
  final String motherName;
  final String parentMobileNumber;
  final String academicYear;
  final String academicYearId;
  final String className;
  final String classId;
  final String sectionName;
  final String sectionId;
  final int? rollNumber;
  final num feeDue;
  final num? attendancePercentage;
  final bool usesTransport;
  final String? villageName;
  final String? villageId;
  final num transportFee;
  final bool isArchived;
}
