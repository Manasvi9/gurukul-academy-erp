final class ReportData {
  const ReportData({
    required this.title,
    required this.headers,
    required this.rows,
  });

  final String title;
  final List<String> headers;
  final List<List<dynamic>> rows;
}
