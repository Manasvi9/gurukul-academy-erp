import '../entities/timetable_entry.dart';

abstract interface class TimetableRepository {
  Future<List<TimetableEntry>> list({
    String? classId,
    String? sectionId,
    String? teacherId,
  });
  Future<List<TimetableTeacher>> teachers();
  Future<void> save(TimetableEntry entry);
  Future<void> delete(String id);
}
