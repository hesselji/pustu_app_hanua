import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class NotificationApiService {
  static const String _endpoint =
      'https://pustu-hanua-notification.vercel.app/api/send-notification';

  static const String _clientNotifyKey = 'pustu-hanua-client-notify-2026';

  /// Dipakai perawat untuk mengirim notifikasi umum ke semua pasien
  static Future<void> sendToPatientTopic({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Perawat belum login');
    }

    final idToken = await user.getIdToken();

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'title': title,
        'body': body,
        'topic': 'pasien',
        'data': data ?? {},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gagal mengirim notifikasi: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Dipakai perawat untuk mengirim notifikasi ke 1 pasien tertentu
  static Future<void> sendToPatientToken({
    required String token,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Perawat belum login');
    }

    final idToken = await user.getIdToken();

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'title': title,
        'body': body,
        'token': token,
        'data': data ?? {},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gagal mengirim notifikasi ke pasien: ${response.statusCode} ${response.body}',
      );
    }
  }

  /// Dipakai aplikasi pasien untuk mengirim notifikasi ke perawat
  static Future<void> sendToPerawatTopicFromPatient({
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Content-Type': 'application/json',
        'X-App-Key': _clientNotifyKey,
      },
      body: jsonEncode({
        'title': title,
        'body': body,
        'topic': 'perawat',
        'data': data ?? {},
      }),
    );

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(
        'Gagal mengirim notifikasi ke perawat: ${response.statusCode} ${response.body}',
      );
    }
  }
}