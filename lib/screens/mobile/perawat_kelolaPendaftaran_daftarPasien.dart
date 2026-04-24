import 'package:flutter/material.dart';
import 'perawat_kelolaPendaftaran_verfikasiPasien.dart';

class PerawatDaftarPasienScreen extends StatelessWidget {
  const PerawatDaftarPasienScreen({super.key});

  final List<Map<String, String>> pasien = const [
    {"nama": "Mahendra", "jam": "10:00"},
    {"nama": "Bagus Rian", "jam": "10:15"},
    {"nama": "Hessel Josef", "jam": "10:30"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Daftar Pasien"),
        backgroundColor: Colors.green,
      ),

      body: ListView.builder(
        itemCount: pasien.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),

            child: ListTile(
              title: Text(pasien[index]["nama"]!),
              subtitle: Text("Jam daftar : ${pasien[index]["jam"]}"),
              trailing: const Icon(Icons.arrow_forward_ios),

              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => PerawatVerifikasiScreen(
                          nama: pasien[index]["nama"]!,
                        ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
