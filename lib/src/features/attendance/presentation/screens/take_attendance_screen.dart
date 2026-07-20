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

final class _TakeAttendanceScreenState
    extends ConsumerState<TakeAttendanceScreen> {
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
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Take Attendance'),
            Text(
              "Mark today's attendance",
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: SizedBox(
            height: 52,
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: isSaving ? null : _save,
              icon: isSaving
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(
                isSaving ? 'Saving Attendance...' : 'Save Attendance',
              ),
            ),
          ),
        ),
      ),
      body: ResponsivePage(
        maxWidth: 950,
        child: AppAsyncView(
          value: roster,
          data: (students) {
            if (students.isEmpty) {
              return const AppEmptyView(
                title: 'No Students',
                message: 'No active students found for this class.',
              );
            }

            for (final student in students) {
              _records.putIfAbsent(student.studentId, () => student);
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.lg),
              itemCount: students.length + 1,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Card(
                    elevation: 0,
                    color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        children: [
                          const CircleAvatar(
                            radius: 24,
                            child: Icon(Icons.groups_outlined),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${students.length} Students Rostered',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'Select status for each student row below',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final student = students[index - 1];
                final current = _records[student.studentId]!;

                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          child: Text(
                            student.studentName.characters.first.toUpperCase(),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                student.studentName,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              Text(
                                'SR No. ${student.srNumber}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                        DropdownButton<AttendanceStatus>(
                          value: current.status,
                          underline: const SizedBox(),
                          borderRadius: BorderRadius.circular(16),
                          items: AttendanceStatus.values
                              .map(
                                (status) => DropdownMenuItem(
                                  value: status,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        status == AttendanceStatus.present
                                            ? Icons.check_circle
                                            : Icons.cancel,
                                        size: 18,
                                        color: status == AttendanceStatus.present
                                            ? Theme.of(context).colorScheme.primary
                                            : Theme.of(context).colorScheme.error,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(status.label),
                                    ],
                                  ),
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
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Future<void> _save() async {
    final saved =
        await ref.read(attendanceSaveControllerProvider.notifier).save(
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
      const SnackBar(
        content: Text('Attendance saved successfully ✅'),
      ),
    );
  }
}