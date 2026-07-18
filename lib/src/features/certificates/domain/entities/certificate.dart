import 'certificate_type.dart';

class Certificate {
  const Certificate({
    required this.id,
    required this.studentId,
    required this.type,
    required this.issueDate,
    required this.certificateNumber,
    this.remarks,
    required this.status,
  });

  final String id;
  final String studentId;
  final CertificateType type;
  final DateTime issueDate;
  final String certificateNumber;
  final String? remarks;
  final CertificateStatus status;
}
