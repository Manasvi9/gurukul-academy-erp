final class AcademicSubject {
  const AcademicSubject({
    required this.id,
    required this.name,
    required this.code,
    required this.classIds,
    required this.displayOrder,
    required this.isActive,
  });

  final String id;
  final String name;
  final String? code;
  final List<String> classIds;
  final int displayOrder;
  final bool isActive;
}
