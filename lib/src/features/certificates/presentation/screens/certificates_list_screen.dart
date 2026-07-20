import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../certificate_providers.dart';

class CertificatesListScreen extends ConsumerWidget {
  const CertificatesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificatesAsync = ref.watch(certificatesListProvider);

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Certificates'),
            Text(
              'Track and issue student credentials',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        elevation: 2,
        onPressed: () => context.push(AppRoute.addCertificate.path),
        label: const Text('Generate Certificate'),
        icon: const Icon(Icons.add),
      ),
      body: ResponsivePage(
        maxWidth: 950,
        child: AppAsyncView(
          value: certificatesAsync,
          data: (certificates) {
            if (certificates.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.workspace_premium_outlined, 
                      size: 70,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No Certificates Generated',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap "Generate Certificate" to create one.',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: certificates.length,
              separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final cert = certificates[index];
                return Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.xs,
                    ),
                    leading: const CircleAvatar(
                      child: Icon(Icons.workspace_premium_outlined),
                    ),
                    title: Text(
                      'Cert #: ${cert.certificateNumber}',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    subtitle: Text(
                      '${cert.type.label} • Status: ${cert.status.label}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    trailing: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
                    ),
                    onTap: () => context.push(
                      AppRoute.certificateDetails.path.replaceFirst(
                        ':certificateId',
                        cert.id,
                      ),
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
}