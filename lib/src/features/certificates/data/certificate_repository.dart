import 'package:supabase_flutter/supabase_flutter.dart';

import '../domain/entities/certificate.dart';
import '../domain/entities/certificate_type.dart';
import '../domain/repositories/certificate_repository.dart';

class SupabaseCertificateRepository implements CertificateRepository {
  final SupabaseClient _client;

  SupabaseCertificateRepository(this._client);

  @override
  Future<List<Certificate>> list({
    String? query,
    CertificateType? type,
    String? studentId,
  }) async {
    var request = _client.from('certificates').select('*');
    if (studentId != null) {
      request = request.eq('student_id', studentId);
    }
    if (type != null) {
      request = request.eq('certificate_type', type.value);
    }
    final normalizedQuery = query?.trim();
    if (normalizedQuery != null && normalizedQuery.isNotEmpty) {
      request = request.ilike('certificate_number', '%$normalizedQuery%');
    }

    final response = await request.order('created_at', ascending: false);

    return response
        .cast<Map<String, Object?>>()
        .map((data) => _mapToCertificate(data.cast<String, dynamic>()))
        .toList();
  }

  @override
  Future<void> create(Certificate certificate) async {
    await _client.from('certificates').insert(_mapFromCertificate(certificate));
  }

  @override
  Future<void> update(Certificate certificate) async {
    await _client
        .from('certificates')
        .update(_mapFromCertificate(certificate))
        .eq('id', certificate.id);
  }

  @override
  Future<void> delete(String id) async {
    await _client.from('certificates').delete().eq('id', id);
  }

  @override
  Future<Certificate> getById(String id) async {
    final response = await _client
        .from('certificates')
        .select('*')
        .eq('id', id)
        .single();
    return _mapToCertificate(response.cast<String, dynamic>());
  }

  Certificate _mapToCertificate(Map<String, dynamic> data) {
    return Certificate(
      id: data['id'] as String,
      studentId: data['student_id'] as String,
      type: CertificateType.fromValue(data['certificate_type'] as String),
      issueDate: DateTime.parse(data['issue_date'] as String),
      certificateNumber: data['certificate_number'] as String,
      remarks: data['remarks'] as String?,
      status: CertificateStatus.fromValue(data['status'] as String),
    );
  }

  Map<String, dynamic> _mapFromCertificate(Certificate certificate) {
    return {
      'student_id': certificate.studentId,
      'certificate_type': certificate.type.value,
      'issue_date': certificate.issueDate.toIso8601String(),
      'certificate_number': certificate.certificateNumber,
      'remarks': certificate.remarks,
      'status': certificate.status.value,
    };
  }
}
