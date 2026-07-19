import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      appBar: AppBar(title: const Text('Generate Certificate')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              decoration: const InputDecoration(labelText: 'Student ID'),
              onChanged: (value) => _studentId = value,
              validator: (value) => value!.isEmpty ? 'Required' : null,
            ),
            DropdownButtonFormField<CertificateType>(
              decoration: const InputDecoration(labelText: 'Certificate Type'),
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
            TextFormField(
              decoration: const InputDecoration(labelText: 'Cert Number'),
              onChanged: (value) => _certificateNumber = value,
              validator: (value) =>
                  value == null || value.trim().isEmpty ? 'Required' : null,
            ),
            if (_type == CertificateType.transfer)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: Text(
                  'This will create a Transfer Certificate draft.',
                ),
              ),
            TextFormField(
              decoration:
                  const InputDecoration(labelText: 'Remarks (optional)'),
              maxLines: 3,
              onChanged: (value) => _remarks = value,
            ),
            const SizedBox(height: 16),
            FilledButton(
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
                  context.pop();
                }
              },
              child: const Text('Generate'),
            ),
          ],
        ),
      ),
    );
  }
}
