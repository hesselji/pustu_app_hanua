import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class NotificationApiService {
  /// Nanti ganti URL ini setelah backend Vercel kamu sudah jadi.
  static const String _endpoint =
      'https://pustu-hanua-notification.vercel.app/api/send-notification';

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
}