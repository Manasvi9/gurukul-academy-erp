final class Validators {
  const Validators._();

  static String? requiredText(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredText(value, fieldName: 'Email');
    if (required != null) {
      return required;
    }

    final trimmed = value!.trim();
    final hasValidShape = RegExp(
      r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
    ).hasMatch(trimmed);

    if (!hasValidShape) {
      return 'Enter a valid email address.';
    }

    return null;
  }

  static String? password(String? value) {
    final required = requiredText(value, fieldName: 'Password');
    if (required != null) {
      return required;
    }

    if (value!.length < 8) {
      return 'Password must be at least 8 characters.';
    }

    return null;
  }

  static String? mobileNumber(String? value) {
    final required = requiredText(value, fieldName: 'Mobile number');
    if (required != null) {
      return required;
    }

    final normalized = value!.trim();
    final hasValidShape = RegExp(r'^[6-9]\d{9}$').hasMatch(normalized);
    if (!hasValidShape) {
      return 'Enter a valid 10 digit mobile number.';
    }

    return null;
  }

  static String? srNumber(String? value) {
    final required = requiredText(value, fieldName: 'SR number');
    if (required != null) {
      return required;
    }

    return null;
  }
}
