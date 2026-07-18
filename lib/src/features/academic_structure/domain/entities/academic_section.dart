final class AcademicSection {
  const AcademicSection({
    required this.id,
    required this.classId,
    required this.className,
    required this.name,
    required this.capacity,
    required this.isActive,
  });

  final String id;
  final String classId;
  final String className;
  final String name;
  final int? capacity;
  final bool isActive;
}
