import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(
  elevation: 0,
  backgroundColor: Colors.transparent,
  title: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'Students',
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      Text(
        'Select Class',
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
    ],
  ),
),
      body: ResponsivePage(
        child: Padding(
          padding: const EdgeInsets.symmetric(
  horizontal: 24,
  vertical: 20,
),
          child: AppAsyncView(
            value: classes,
            data: (items) {
              if (items.isEmpty) {
                return const Padding(
  padding: EdgeInsets.symmetric(vertical: 32),
  child: AppEmptyView(
    title: 'No Classes Found',
    message: 'There are no active classes for this academic year.',
  ),
);
              }
              return ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const SizedBox.shrink(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Card(
  elevation: 3,
  margin: const EdgeInsets.only(bottom: 14),
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  ),
  child: InkWell(
    borderRadius: BorderRadius.circular(18),
    onTap: () {
      context.go(
        '/students/classes/${item.id}/sections'
        '?academicYearId=$academicYearId',
      );
    },
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF17375E).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.school_rounded,
              color: Color(0xFF17375E),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              item.name,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey,
          ),
        ],
      ),
    ),
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
