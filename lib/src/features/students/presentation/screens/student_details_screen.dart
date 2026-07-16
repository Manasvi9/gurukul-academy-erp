import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../../authentication/domain/entities/auth_role.dart';
import '../../../authentication/presentation/providers/auth_providers.dart';
import '../providers/student_providers.dart';
import '../widgets/student_info_tile.dart';

final class StudentDetailsScreen extends ConsumerWidget {
  const StudentDetailsScreen({
    required this.studentId,
    super.key,
  });

  final String studentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(studentDetailsProvider(studentId));
    final authUser = ref.watch(authControllerProvider).user;
    final canEdit = switch (authUser?.role) {
      AuthRole.systemAdmin || AuthRole.director || AuthRole.principal => true,
      _ => false,
    };

    return AppAsyncView(
      value: student,
      data: (detail) {
        return DefaultTabController(
          length: 5,
          child: Scaffold(
            appBar: AppBar(
              title: Text(detail.name),
              actions: [
                if (canEdit)
                  IconButton(
                    tooltip: 'Edit',
                    onPressed: () => context.go('/students/$studentId/edit'),
                    icon: const Icon(Icons.edit_outlined),
                  ),
                if (canEdit)
                  IconButton(
                    tooltip: 'Archive Student',
                    onPressed: () => _archive(context, ref),
                    icon: const Icon(Icons.archive_outlined),
                  ),
              ],
              bottom: const TabBar(
                isScrollable: true,
                tabs: [
                  Tab(text: 'Profile'),
                  Tab(text: 'Fees'),
                  Tab(text: 'Attendance'),
                  Tab(text: 'Marks'),
                  Tab(text: 'TC'),
                ],
              ),
            ),
            body: TabBarView(
              children: [
                ResponsivePage(
                  child: ListView(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    children: [
                      StudentInfoTile(label: 'SR Number', value: detail.srNumber),
                      StudentInfoTile(
                        label: 'Admission Date',
                        value: DateFormatter.displayDate(detail.admissionDate),
                      ),
                      StudentInfoTile(label: 'Gender', value: detail.gender.label),
                      StudentInfoTile(
                        label: 'DOB',
                        value: DateFormatter.displayDate(detail.dateOfBirth),
                      ),
                      StudentInfoTile(label: 'Father', value: detail.fatherName),
                      StudentInfoTile(label: 'Mother', value: detail.motherName),
                      StudentInfoTile(
                        label: 'Parent Mobile',
                        value: detail.parentMobileNumber,
                      ),
                      StudentInfoTile(
                        label: 'Class',
                        value: '${detail.className} - ${detail.sectionName}',
                      ),
                      StudentInfoTile(
                        label: 'Transport',
                        value: detail.usesTransport
                            ? '${detail.villageName ?? '-'} (${detail.transportFee})'
                            : 'No',
                      ),
                    ],
                  ),
                ),
                AppEmptyView(
                  title: 'Fee Summary',
                  message: 'Current due: ${detail.feeDue.toStringAsFixed(0)}',
                ),
                AppEmptyView(
                  title: 'Attendance Summary',
                  message: detail.attendancePercentage == null
                      ? 'Attendance records are not available yet.'
                      : '${detail.attendancePercentage!.toStringAsFixed(1)}%',
                ),
                const AppEmptyView(
                  title: 'Marks',
                  message: 'Marks will be available from the Exams module.',
                ),
                const AppEmptyView(
                  title: 'Transfer Certificate',
                  message: 'Transfer certificate actions belong to the TC module.',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _archive(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archive student?'),
          content: const Text(
            'Archived students are hidden from normal student lists.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !context.mounted) {
      return;
    }

    final archived = await ref
        .read(archiveStudentControllerProvider.notifier)
        .archive(studentId);
    if (!context.mounted || !archived) {
      return;
    }
    context.go('/students');
  }
}
