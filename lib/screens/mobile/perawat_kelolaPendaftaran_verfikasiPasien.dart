import 'package:flutter/material.dart';

class PerawatVerifikasiScreen extends StatelessWidget {
  final String nama;

  const PerawatVerifikasiScreen({super.key, required this.nama});

  void tampilAlert(BuildContext context, String pesan) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(pesan)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Verifikasi Daftar Berobat"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Pasien : $nama",
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            TextField(
              decoration: InputDecoration(
                labelText: "Keluhan Pasien",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () {
                      tampilAlert(context, "Daftar Berobat tidak diterima");
                    },
                    child: const Text("TOLAK"),
                  ),
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                    ),
                    onPressed: () {
                      tampilAlert(context, "Daftar berobat diterima");
                    },
                    child: const Text("DITERIMA"),
                  ),
                ),
              ],
            ),

            const Spacer(),

            const Center(child: Text("© Pustu Hanua 2026")),
          ],
        ),
      ),
    );
  }
}
