import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/attendance_record.dart';
import '../../domain/entities/attendance_status.dart';
import '../providers/attendance_providers.dart';

final class TakeAttendanceScreen extends ConsumerStatefulWidget {
  const TakeAttendanceScreen({
    required this.academicYearId,
    required this.classId,
    required this.sectionId,
    super.key,
  });

  final String academicYearId;
  final String classId;
  final String sectionId;

  @override
  ConsumerState<TakeAttendanceScreen> createState() =>
      _TakeAttendanceScreenState();
}

final class _TakeAttendanceScreenState extends ConsumerState<TakeAttendanceScreen> {
  final _records = <String, AttendanceRecord>{};

  @override
  Widget build(BuildContext context) {
    final request = AttendanceRosterRequest(
      academicYearId: widget.academicYearId,
      classId: widget.classId,
      sectionId: widget.sectionId,
    );
    final roster = ref.watch(attendanceRosterProvider(request));
    final isSaving = ref.watch(attendanceSaveControllerProvider).isLoading;

    return Scaffold(
      appBar: AppBar(title: const Text('Take Attendance')),
      body: ResponsivePage(
        maxWidth: 900,
        child: AppAsyncView(
          value: roster,
          data: (students) {
            if (students.isEmpty) {
              return const AppEmptyView(
                title: 'No students',
                message: 'No active students found for this class.',
              );
            }
            for (final student in students) {
              _records.putIfAbsent(student.studentId, () => student);
            }

            return ListView(
              padding: const EdgeInsets.all(AppSpacing.md),
              children: [
                ...students.map((student) {
                  final current = _records[student.studentId]!;
                  return Card(
                    child: ListTile(
                      title: Text(student.studentName),
                      subtitle: Text(student.srNumber),
                      trailing: DropdownButton<AttendanceStatus>(
                        value: current.status,
                        items: AttendanceStatus.values
                            .map(
                              (status) => DropdownMenuItem(
                                value: status,
                                child: Text(status.label),
                              ),
                            )
                            .toList(),
                        onChanged: (status) {
                          if (status == null) return;
                          setState(() {
                            _records[student.studentId] = AttendanceRecord(
                              studentId: current.studentId,
                              studentName: current.studentName,
                              srNumber: current.srNumber,
                              status: status,
                              note: current.note,
                            );
                          });
                        },
                      ),
                    ),
                  );
                }),
                const SizedBox(height: AppSpacing.md),
                FilledButton.icon(
                  onPressed: isSaving ? null : _save,
                  icon: const Icon(Icons.save_outlined),
                  label: Text(isSaving ? 'Saving...' : 'Save Attendance'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    final saved = await ref.read(attendanceSaveControllerProvider.notifier).save(
          academicYearId: widget.academicYearId,
          classId: widget.classId,
          sectionId: widget.sectionId,
          date: DateTime.now(),
          records: _records.values.toList(),
        );
    if (!mounted || !saved) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Attendance saved.')),
    );
  }
}
