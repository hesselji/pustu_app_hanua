class PatientAuthHelper {
  static String normalizePhone(String phone) {
    String value = phone.trim().replaceAll(RegExp(r'[^0-9+]'), '');

    if (value.startsWith('+62')) {
      value = '0${value.substring(3)}';
    } else if (value.startsWith('62')) {
      value = '0${value.substring(2)}';
    }

    return value;
  }

  static String phoneToEmail(String phone) {
    final normalizedPhone = normalizePhone(phone);
    return '$normalizedPhone@pasien.pustu-hanua.app';
  }

  static bool isValidPhone(String phone) {
    final normalizedPhone = normalizePhone(phone);
    return normalizedPhone.startsWith('08') && normalizedPhone.length >= 10;
  }
}