enum StudentGender {
  male('male', 'Male'),
  female('female', 'Female'),
  other('other', 'Other');

  const StudentGender(this.value, this.label);

  final String value;
  final String label;

  static StudentGender fromValue(String value) {
    return StudentGender.values.firstWhere(
      (gender) => gender.value == value,
      orElse: () => throw FormatException('Unsupported gender: $value'),
    );
  }
}
