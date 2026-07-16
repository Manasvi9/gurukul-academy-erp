final class AcademicYear {
  const AcademicYear({
    required this.id,
    required this.name,
    required this.startsOn,
    required this.endsOn,
    required this.isActive,
  });

  final String id;
  final String name;
  final DateTime startsOn;
  final DateTime endsOn;
  final bool isActive;
}
