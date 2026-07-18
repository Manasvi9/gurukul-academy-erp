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
          .map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.lg),
              child: _DashboardSection(section: section),
            ),
          )
          .toList(),
    );
  }
}

final class _DashboardSection extends StatelessWidget {
  const _DashboardSection({required this.section});

  final DashboardSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(section.title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: AppSpacing.sm),
        if (section.items.isEmpty)
          AppEmptyView(title: 'Nothing to show', message: section.emptyMessage)
        else
          ...section.items.map(
            (item) => Card(
              child: ListTile(
                title: Text(item.title),
                subtitle: Text(item.subtitle),
              ),
            ),
          ),
      ],
    );
  }
}
