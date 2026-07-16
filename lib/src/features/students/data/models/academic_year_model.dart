import '../../domain/entities/academic_year.dart';

final class AcademicYearModel extends AcademicYear {
  const AcademicYearModel({
    required super.id,
    required super.name,
    required super.startsOn,
    required super.endsOn,
    required super.isActive,
  });

  factory AcademicYearModel.fromJson(Map<String, Object?> json) {
    return AcademicYearModel(
      id: json['id'] as String,
      name: json['name'] as String,
      startsOn: DateTime.parse(json['starts_on'] as String),
      endsOn: DateTime.parse(json['ends_on'] as String),
      isActive: json['is_active'] as bool,
    );
  }
}
