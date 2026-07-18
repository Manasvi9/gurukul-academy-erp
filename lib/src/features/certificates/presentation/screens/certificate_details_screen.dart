import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/app_async_view.dart';
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
      appBar: AppBar(title: const Text('Certificate Details')),
      body: AppAsyncView(
        value: certificateAsync,
        data: (certificate) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              ListTile(
                title: const Text('Certificate Number'),
                subtitle: Text(certificate.certificateNumber),
              ),
              ListTile(
                title: const Text('Type'),
                subtitle: Text(certificate.type.label),
              ),
              ListTile(
                title: const Text('Status'),
                subtitle: Text(certificate.status.label),
              ),
              if (certificate.remarks != null &&
                  certificate.remarks!.isNotEmpty)
                ListTile(
                  title: const Text('Remarks'),
                  subtitle: Text(certificate.remarks!),
                ),
            ],
          );
        },
      ),
    );
  }
}
