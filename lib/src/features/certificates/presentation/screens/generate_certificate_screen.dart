import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/responsive_page.dart';
import '../../domain/entities/certificate.dart';
import '../../domain/entities/certificate_type.dart';
import '../certificate_providers.dart';

class GenerateCertificateScreen extends ConsumerStatefulWidget {
  const GenerateCertificateScreen({super.key});

  @override
  ConsumerState<GenerateCertificateScreen> createState() =>
      _GenerateCertificateScreenState();
}

class _GenerateCertificateScreenState
    extends ConsumerState<GenerateCertificateScreen> {
  final _formKey = GlobalKey<FormState>();
  String _studentId = '';
  CertificateType _type = CertificateType.bonafide;
  String _certificateNumber = '';
  String _remarks = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: false,
        titleSpacing: 20,
        title: const Text('Generate Certificate'),
      ),
      body: ResponsivePage(
        maxWidth: 650,
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Card(
                elevation: 0,
                color: Theme.of(context).colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        child: Icon(
                          Icons.workspace_premium_outlined,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Generate Certificate',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Create a new student certificate reference block.',
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Student ID',
                  prefixIcon: Icon(Icons.person_outline),
                ),
                onChanged: (value) => _studentId = value,
                validator: (value) => value!.isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<CertificateType>(
                decoration: const InputDecoration(
                  labelText: 'Certificate Type',
                  prefixIcon: Icon(Icons.layers_outlined),
                ),
                initialValue: _type,
                items: CertificateType.values
                    .map(
                      (type) => DropdownMenuItem(
                        value: type,
                        child: Text(type.label),
                      ),
                    )
                    .toList(),
                onChanged: (value) => setState(() => _type = value!),
              ),
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Cert Number',
                  prefixIcon: Icon(Icons.numbers_outlined),
                ),
                onChanged: (value) => _certificateNumber = value,
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              if (_type == CertificateType.transfer) ...[
                const SizedBox(height: AppSpacing.sm),
                Material(
                  color: Theme.of(context).colorScheme.secondaryContainer,
                  borderRadius: BorderRadius.circular(8),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, size: 16, color: Theme.of(context).colorScheme.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'This will create a Transfer Certificate draft.',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.md),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Remarks (optional)',
                  prefixIcon: Icon(Icons.notes_outlined),
                ),
                maxLines: 3,
                onChanged: (value) => _remarks = value,
              ),
              const SizedBox(height: 24),
              SizedBox(
                height: 52,
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      final certificate = Certificate(
                        id: '',
                        studentId: _studentId,
                        type: _type,
                        issueDate: DateTime.now(),
                        certificateNumber: _certificateNumber.trim(),
                        remarks: _remarks.trim().isEmpty ? null : _remarks.trim(),
                        status: CertificateStatus.draft,
                      );
                      final wasCreated = await ref
                          .read(createCertificateControllerProvider.notifier)
                          .create(certificate);
                      if (!context.mounted) return;
                      if (!wasCreated) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Unable to generate certificate.'),
                          ),
                        );
                        return;
                      }
                      ref.invalidate(certificatesListProvider);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Certificate generated successfully ✅'),
                        ),
                      );
                      context.pop();
                    }
                  },
                  child: const Text('Generate'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}