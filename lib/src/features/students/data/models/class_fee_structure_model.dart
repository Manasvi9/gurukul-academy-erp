import '../../domain/entities/class_fee_structure.dart';

final class ClassFeeStructureModel extends ClassFeeStructure {
  const ClassFeeStructureModel({
    required super.id,
    required super.academicYearId,
    required super.classId,
    required super.tuitionFee,
    required super.admissionFee,
    required super.examFee,
  });

  factory ClassFeeStructureModel.fromJson(Map<String, Object?> json) {
    return ClassFeeStructureModel(
      id: json['id'] as String,
      academicYearId: json['academic_year_id'] as String,
      classId: json['class_id'] as String,
      tuitionFee: json['tuition_fee'] as num,
      admissionFee: json['admission_fee'] as num,
      examFee: json['exam_fee'] as num,
    );
  }
}
