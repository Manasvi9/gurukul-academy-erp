class ClassFeeStructure {
  const ClassFeeStructure({
    required this.id,
    required this.academicYearId,
    required this.classId,
    required this.tuitionFee,
    required this.admissionFee,
    required this.examFee,
  });

  final String id;
  final String academicYearId;
  final String classId;
  final num tuitionFee;
  final num admissionFee;
  final num examFee;

  num get totalFee => tuitionFee + admissionFee + examFee;
}
