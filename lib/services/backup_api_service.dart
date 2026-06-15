import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class BackupApiService {
  static const String _baseUrl = 'https://pustu-hanua-notification.vercel.app';

  static Future<Map<String, dynamic>> createBackup() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Perawat belum login');
    }

    final idToken = await user.getIdToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/backup-data'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({}),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['message'] ?? 'Gagal membuat backup');
    }

    return data;
  }

  static Future<Map<String, dynamic>> restoreBackup({
    required Map<String, dynamic> backup,
  }) async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      throw Exception('Perawat belum login');
    }

    final idToken = await user.getIdToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/api/restore-data'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $idToken',
      },
      body: jsonEncode({
        'backup': backup,
      }),
    );

    final data = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception(data['message'] ?? 'Gagal melakukan recovery');
    }

    return data;
  }
}