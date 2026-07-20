import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_empty_view.dart';
import '../../domain/entities/dashboard_section.dart';

final class DashboardSections extends StatelessWidget {
  const DashboardSections({
    required this.sections,
    super.key,
  });

  final List<DashboardSection> sections;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: sections
          .map((section) => _DashboardSectionItem(section: section))
          .toList(),
    );
  }
}

final class _DashboardSectionItem extends StatelessWidget {
  const _DashboardSectionItem({required this.section});

  final DashboardSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          section.title,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        const SizedBox(height: AppSpacing.sm),
        if (section.items.isEmpty)
          AppEmptyView(
            title: 'Nothing to show',
            message: section.emptyMessage,
          )
        else
          ...section.items.map(
            (item) => Card(
              elevation: 3,
              shadowColor: Colors.black12,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18),
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () {},
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
                        child: Icon(
                          _iconForTitle(item.title),
                          color: const Color(0xFF17375E),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              item.subtitle,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }

  IconData _iconForTitle(String title) {
    return switch (title.toLowerCase()) {
      _ when title.contains('Timetable') => Icons.calendar_month_outlined,
      _ when title.contains('Exam') => Icons.quiz_outlined,
      _ when title.contains('Assignment') => Icons.assignment_outlined,
      _ => Icons.circle_outlined,
    };
  }
}
