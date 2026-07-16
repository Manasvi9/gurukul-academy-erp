import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../providers/student_providers.dart';

final class StudentSectionListScreen extends ConsumerWidget {
  const StudentSectionListScreen({
    required this.academicYearId,
    required this.classId,
    super.key,
  });

  final String academicYearId;
  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(sectionsProvider(classId));

    return Scaffold(
      appBar: AppBar(title: const Text('Select Section')),
      body: ResponsivePage(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppAsyncView(
            value: sections,
            data: (items) {
              if (items.isEmpty) {
                return const AppEmptyView(
                  title: 'No sections',
                  message: 'No active sections are available.',
                );
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    title: Text(item.name),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.go(
                        '/students/classes/$classId/sections/${item.id}'
                        '?academicYearId=$academicYearId',
                      );
                    },
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
