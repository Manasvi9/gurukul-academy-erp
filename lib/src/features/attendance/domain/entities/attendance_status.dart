enum AttendanceStatus {
  present('present', 'Present'),
  absent('absent', 'Absent'),
  late('late', 'Late'),
  leave('leave', 'Leave');

  const AttendanceStatus(this.value, this.label);

  final String value;
  final String label;
}
