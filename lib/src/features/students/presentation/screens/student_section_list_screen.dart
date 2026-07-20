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
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Section'),
            Text(
              'Choose a section to view students',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      body: ResponsivePage(
        maxWidth: 700,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: AppAsyncView(
            value: sections,
            data: (items) {
              if (items.isEmpty) {
                return const AppEmptyView(
                  title: 'No Sections Available',
                  message: 'There are no active sections in this class.',
                );
              }

              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: AppSpacing.md),
                itemBuilder: (context, index) {
                  final item = items[index];

                  return Card(
                    elevation: 2,
                    clipBehavior: Clip.antiAlias,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.sm,
                      ),
                      leading: CircleAvatar(
                        child: Text(
                          item.name.characters.first.toUpperCase(),
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      subtitle: const Text('Tap to view students'),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded),
                      onTap: () {
                        context.go(
                          '/students/classes/$classId/sections/${item.id}'
                          '?academicYearId=$academicYearId',
                        );
                      },
                    ),
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