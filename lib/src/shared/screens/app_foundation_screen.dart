import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/network_providers.dart';
import '../../core/network/network_status.dart';
import '../../core/theme/app_spacing.dart';
import '../widgets/offline_banner.dart';
import '../widgets/responsive_page.dart';

final class AppFoundationScreen extends ConsumerWidget {
  const AppFoundationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gurukul Academy'),
      ),
      body: Column(
        children: [
          if (networkStatus.valueOrNull == NetworkStatus.offline)
            const OfflineBanner(),
          Expanded(
            child: ResponsivePage(
              child: ListView(
                padding: const EdgeInsets.all(AppSpacing.md),
                children: [
                  Text(
                    'Project foundation is ready.',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Business features will be added after approval.',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  const _FoundationItem(
                    icon: Icons.security,
                    title: 'Security posture',
                    subtitle:
                        'Flutter is treated as an untrusted client. Critical rules belong in the backend.',
                  ),
                  const _FoundationItem(
                    icon: Icons.route,
                    title: 'Routing',
                    subtitle: 'GoRouter is configured for feature routes.',
                  ),
                  const _FoundationItem(
                    icon: Icons.account_tree_outlined,
                    title: 'Architecture',
                    subtitle:
                        'Feature-first Clean Architecture with Riverpod dependency injection.',
                  ),
                  const _FoundationItem(
                    icon: Icons.wifi_off_outlined,
                    title: 'Offline foundation',
                    subtitle:
                        'Network monitoring and offline queue contracts are in place.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

final class _FoundationItem extends StatelessWidget {
  const _FoundationItem({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        subtitle: Text(subtitle),
      ),
    );
  }
}
