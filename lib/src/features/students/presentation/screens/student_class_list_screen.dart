import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../providers/student_providers.dart';

final class StudentClassListScreen extends ConsumerWidget {
  const StudentClassListScreen({
    required this.academicYearId,
    super.key,
  });

  final String academicYearId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final classes = ref.watch(classesProvider(academicYearId));

    return Scaffold(
      appBar: AppBar(title: const Text('Select Class')),
      body: ResponsivePage(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: AppAsyncView(
            value: classes,
            data: (items) {
              if (items.isEmpty) {
                return const AppEmptyView(
                  title: 'No classes',
                  message: 'No active classes are available.',
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
                        '/students/classes/${item.id}/sections'
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
