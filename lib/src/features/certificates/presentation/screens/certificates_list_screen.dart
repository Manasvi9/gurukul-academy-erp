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
      appBar: AppBar(title: const Text('Certificates')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoute.addCertificate.path),
        label: const Text('Generate Certificate'),
        icon: const Icon(Icons.add),
      ),
      body: ResponsivePage(
        maxWidth: 800,
        child: AppAsyncView(
          value: certificatesAsync,
          data: (certificates) {
            return ListView.builder(
              itemCount: certificates.length,
              itemBuilder: (context, index) {
                final cert = certificates[index];
                return Card(
                  margin: const EdgeInsets.all(AppSpacing.sm),
                  child: ListTile(
                    title: Text('Cert #: ${cert.certificateNumber}'),
                    subtitle: Text(
                      '${cert.type.label} - Status: ${cert.status.label}',
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
