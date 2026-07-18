import '../entities/report_data.dart';

enum ReportType {
  student,
  teacher,
  attendance,
  feeCollection,
  feeDue,
  examResult,
  certificate,
  homework,
  marksSummary,
}

abstract interface class ReportRepository {
  Future<ReportData> getReportData(
    ReportType type, {
    String? academicSessionId,
    String? classId,
    String? sectionId,
    DateTime? startDate,
    DateTime? endDate,
  });
}
