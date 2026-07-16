import '../../domain/entities/student_form_data.dart';

final class StudentFormDto {
  const StudentFormDto._(this.body);

  factory StudentFormDto.fromEntity(StudentFormData data) {
    return StudentFormDto._({
      'sr_number': data.srNumber.trim(),
      'admission_date': _dateOnly(data.admissionDate),
      'student_name': data.name.trim(),
      'gender': data.gender.value,
      'date_of_birth': _dateOnly(data.dateOfBirth),
      'father_name': data.fatherName.trim(),
      'mother_name': data.motherName.trim(),
      'parent_mobile_number': data.parentMobileNumber.trim(),
      'academic_year_id': data.academicYearId,
      'class_id': data.classId,
      'section_id': data.sectionId,
      'scholarship_discount': data.scholarshipDiscount,
      'uses_transport': data.usesTransport,
      'village_id': data.villageId,
    });
  }

  final Map<String, Object?> body;

  static String _dateOnly(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }
}
