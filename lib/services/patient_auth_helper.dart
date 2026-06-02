import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PatientAuthHelper {
  static String normalizePhone(String phone) {
    String value = phone.trim();
    value = value.replaceAll(RegExp(r'[^0-9+]'), '');

    if (value.startsWith('+62')) {
      value = '0${value.substring(3)}';
    } else if (value.startsWith('62')) {
      value = '0${value.substring(2)}';
    } else if (value.startsWith('8')) {
      value = '0$value';
    }

    return value;
  }

  static bool isValidPhone(String phone) {
    final normalizedPhone = normalizePhone(phone);

    return normalizedPhone.startsWith('08') &&
        normalizedPhone.length >= 10 &&
        normalizedPhone.length <= 13;
  }

  static String generateSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }

  static String hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:${password.trim()}');
    return sha256.convert(bytes).toString();
  }

  static Future<void> savePatientSession({
    required String uid,
    required String nama,
    required String nik,
    required String phone,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString('patient_uid', uid);
    await prefs.setString('patient_nama', nama);
    await prefs.setString('patient_nik', nik);
    await prefs.setString('patient_phone', phone);
    await prefs.setBool('is_patient_logged_in', true);
  }

  static Future<String?> getCurrentPatientUid() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('is_patient_logged_in') ?? false;

    if (!isLoggedIn) return null;

    return prefs.getString('patient_uid');
  }

  static Future<void> clearPatientSession() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove('patient_uid');
    await prefs.remove('patient_nama');
    await prefs.remove('patient_nik');
    await prefs.remove('patient_phone');
    await prefs.remove('is_patient_logged_in');
  }
}