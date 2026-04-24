import 'package:flutter/material.dart';
import 'perawat_kelolaPendaftaran_daftarPasien.dart';

class PerawatKelolaPendaftaranScreen extends StatefulWidget {
  const PerawatKelolaPendaftaranScreen({super.key});

  @override
  State<PerawatKelolaPendaftaranScreen> createState() =>
      _PerawatKelolaPendaftaranScreenState();
}

class _PerawatKelolaPendaftaranScreenState
    extends State<PerawatKelolaPendaftaranScreen> {
  DateTime? selectedDate;
 
  Future<void> pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Kelola Pendaftaran"),
        backgroundColor: Colors.green,
      ),

      body: Column(
        children: [
          const SizedBox(height: 30),

          const Text(
            "KELOLA PENDAFTARAN",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 30),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: TextField(
              readOnly: true,
              onTap: pilihTanggal,
              decoration: InputDecoration(
                hintText:
                    selectedDate == null
                        ? "Masukkan Tanggal Berobat"
                        : "${selectedDate!.day}-${selectedDate!.month}-${selectedDate!.year}",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PerawatDaftarPasienScreen(),
                ),
              );
            },
            child: const Text("KIRIM"),
          ),

          const Spacer(),

          const Padding(
            padding: EdgeInsets.all(12),
            child: Text("© Pustu Hanua 2026"),
          ),
        ],
      ),
    );
  }
}
