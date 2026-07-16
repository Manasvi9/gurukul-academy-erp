import 'package:flutter_test/flutter_test.dart';
import 'package:gurukul_academy_erp/src/features/students/data/dto/student_form_dto.dart';
import 'package:gurukul_academy_erp/src/features/students/domain/entities/student_form_data.dart';
import 'package:gurukul_academy_erp/src/features/students/domain/entities/student_gender.dart';

void main() {
  test('StudentFormDto trims text fields and serializes backend keys', () {
    final dto = StudentFormDto.fromEntity(
      StudentFormData(
        srNumber: ' SR-125 ',
        admissionDate: DateTime(2026, 7, 16),
        name: ' Ananya Sharma ',
        gender: StudentGender.female,
        dateOfBirth: DateTime(2012, 8, 15),
        fatherName: ' Raj Sharma ',
        motherName: ' Kavita Sharma ',
        parentMobileNumber: '9876543210',
        academicYearId: 'year-id',
        classId: 'class-id',
        sectionId: 'section-id',
        scholarshipDiscount: 500,
        usesTransport: true,
        villageId: 'village-id',
      ),
    );

    expect(dto.body['sr_number'], 'SR-125');
    expect(dto.body['student_name'], 'Ananya Sharma');
    expect(dto.body['gender'], 'female');
    expect(dto.body['father_name'], 'Raj Sharma');
    expect(dto.body['mother_name'], 'Kavita Sharma');
    expect(dto.body['uses_transport'], isTrue);
    expect(dto.body['village_id'], 'village-id');
  });
}
