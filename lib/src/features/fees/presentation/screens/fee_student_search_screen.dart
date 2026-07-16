import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../providers/fee_providers.dart';

final class FeeStudentSearchScreen extends ConsumerWidget {
  const FeeStudentSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final results = ref.watch(feeStudentSearchProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Search Student Fees')),
      body: ResponsivePage(
        child: ListView(
          padding: const EdgeInsets.all(AppSpacing.md),
          children: [
            TextField(
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Student name, SR number, parent or mobile',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) {
                ref.read(feeStudentSearchProvider.notifier).search(value);
              },
            ),
            const SizedBox(height: AppSpacing.lg),
            AppAsyncView(
              value: results,
              data: (students) {
                if (students.isEmpty) {
                  return const AppEmptyView(
                    title: 'No students',
                    message: 'Search for a student to view fee details.',
                  );
                }
                return Column(
                  children: students.map((student) {
                    return Card(
                      child: ListTile(
                        title: Text(student.name),
                        subtitle: Text(student.srNumber),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.go('/students/${student.id}'),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
