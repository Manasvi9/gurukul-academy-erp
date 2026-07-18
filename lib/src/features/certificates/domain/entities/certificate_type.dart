enum CertificateType {
  bonafide('bonafide', 'Bonafide Certificate'),
  character('character', 'Character Certificate'),
  transfer('transfer', 'Transfer Certificate'),
  study('study', 'Study Certificate'),
  custom('custom', 'Custom Certificate');

  const CertificateType(this.value, this.label);
  final String value;
  final String label;

  static CertificateType fromValue(String value) =>
      CertificateType.values.firstWhere((e) => e.value == value);
}

enum CertificateStatus {
  draft('draft', 'Draft'),
  issued('issued', 'Issued'),
  revoked('revoked', 'Revoked');

  const CertificateStatus(this.value, this.label);
  final String value;
  final String label;

  static CertificateStatus fromValue(String value) =>
      CertificateStatus.values.firstWhere((e) => e.value == value);
}
