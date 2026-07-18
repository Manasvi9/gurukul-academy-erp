import '../entities/certificate.dart';
import '../entities/certificate_type.dart';

abstract interface class CertificateRepository {
  Future<List<Certificate>> list({
    String? query,
    CertificateType? type,
    String? studentId,
  });
  Future<void> create(Certificate certificate);
  Future<void> update(Certificate certificate);
  Future<void> delete(String id);
  Future<Certificate> getById(String id);
}
