final class TimetableEntry {
  const TimetableEntry({required this.id, required this.classId, required this.className, required this.sectionId, required this.sectionName, required this.subjectId, required this.subjectName, required this.teacherId, required this.teacherName, required this.dayOfWeek, required this.startTime, required this.endTime, this.room});
  final String id; final String classId; final String className; final String sectionId; final String sectionName; final String subjectId; final String subjectName; final String teacherId; final String teacherName; final int dayOfWeek; final String startTime; final String endTime; final String? room;
  String get dayLabel => const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dayOfWeek - 1];
}

final class TimetableTeacher { const TimetableTeacher(this.id, this.name); final String id; final String name; }
