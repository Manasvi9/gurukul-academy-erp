import 'package:flutter/material.dart';

import '../../domain/entities/student_summary.dart';

final class StudentSummaryTable extends StatelessWidget {
  const StudentSummaryTable({
    required this.students,
    required this.onStudentTap,
    super.key,
  });

  final List<StudentSummary> students;
  final ValueChanged<StudentSummary> onStudentTap;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        headingRowHeight: 40,
        dataRowMinHeight: 44,
        dataRowMaxHeight: 48,
        columns: const [
          DataColumn(label: Text('Roll No')),
          DataColumn(label: Text('Student Name')),
          DataColumn(label: Text('SR Number')),
          DataColumn(label: Text('Fee Due')),
          DataColumn(label: Text('Attendance %')),
        ],
        rows: students.map((student) {
          return DataRow(
            onSelectChanged: (_) => onStudentTap(student),
            cells: [
              DataCell(Text(student.rollNumber?.toString() ?? '-')),
              DataCell(Text(student.name)),
              DataCell(Text(student.srNumber)),
              DataCell(Text(student.feeDue.toStringAsFixed(0))),
              DataCell(
                Text(
                  student.attendancePercentage == null
                      ? '-'
                      : student.attendancePercentage!.toStringAsFixed(1),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}
