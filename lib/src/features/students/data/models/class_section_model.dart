import '../../domain/entities/class_section.dart';

final class ClassSectionModel extends ClassSection {
  const ClassSectionModel({
    required super.id,
    required super.classId,
    required super.name,
    required super.displayOrder,
  });

  factory ClassSectionModel.fromJson(Map<String, Object?> json) {
    return ClassSectionModel(
      id: json['id'] as String,
      classId: json['class_id'] as String,
      name: json['name'] as String,
      displayOrder: json['display_order'] as int,
    );
  }
}
