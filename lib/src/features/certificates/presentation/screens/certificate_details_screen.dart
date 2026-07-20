import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/app_async_view.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../certificate_providers.dart';

class CertificateDetailsScreen extends ConsumerWidget {
  const CertificateDetailsScreen({
    required this.certificateId,
    super.key,
  });

  final String certificateId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificateAsync = ref.watch(
      certificateDetailsProvider(certificateId),
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Text('Certificate Details'),
      ),
      body: ResponsivePage(
        maxWidth: 700,
        child: AppAsyncView(
          value: certificateAsync,
          data: (certificate) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Card(
                  elevation: 1,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.workspace_premium_outlined,
                          size: 64,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          certificate.type.label,
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  title: const Text('Certificate Number'),
                  subtitle: Text(
                    certificate.certificateNumber,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ListTile(
                  title: const Text('Type'),
                  subtitle: Text(
                    certificate.type.label,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ),
                ListTile(
                  title: const Text('Status'),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Chip(
                      label: Text(certificate.status.label),
                      visualDensity: VisualDensity.compact,
                    ),
                  ),
                ),
                if (certificate.remarks != null &&
                    certificate.remarks!.isNotEmpty)
                  ListTile(
                    title: const Text('Remarks'),
                    subtitle: Text(
                      certificate.remarks!,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}