import '../../domain/entities/school_class.dart';

final class SchoolClassModel extends SchoolClass {
  const SchoolClassModel({
    required super.id,
    required super.name,
    required super.displayOrder,
  });

  factory SchoolClassModel.fromJson(Map<String, Object?> json) {
    return SchoolClassModel(
      id: json['id'] as String,
      name: json['name'] as String,
      displayOrder: json['display_order'] as int,
    );
  }
}
