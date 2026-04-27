import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientCheckScreen extends StatefulWidget {
  const PatientCheckScreen({super.key});

  @override
  State<PatientCheckScreen> createState() => _PatientCheckScreenState();
}

class _PatientCheckScreenState extends State<PatientCheckScreen> {

  /// 🔥 CONTROLLER
  final TextEditingController nikController = TextEditingController();

  DateTime? selectedDate;
  Map<String, dynamic>? resultData;

  /// 🔥 DATE PICKER
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

  /// 🔥 CEK DATA KE FIRESTORE
  Future<void> cekData() async {
    if (nikController.text.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Isi NIK dan Tanggal terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('registrations')
          .where('nik', isEqualTo: nikController.text)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          resultData = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data tidak ditemukan"),
          ),
        );
        return;
      }

      /// Ambil data pertama
      setState(() {
        resultData = snapshot.docs.first.data() as Map<String, dynamic>;
      });

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  _logo("Kemenkes"),
                  const SizedBox(width: 10),
                  _logo("Pustu"),
                  const Spacer(),
                  const Text("Pustu Hanua",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const Divider(),

            /// CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 10),

                    const Center(
                      child: Text(
                        "LIHAT DAFTAR BEROBAT",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔥 INPUT NIK
                    const Text("Masukkan NIK:"),
                    const SizedBox(height: 10),
                    _inputField(controller: nikController),

                    const SizedBox(height: 20),

                    /// 🔥 TANGGAL
                    const Text("Masukkan Tanggal Berobat:"),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: pilihTanggal,
                      child: Container(
                        height: 50,
                        color: Colors.grey[300],
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          selectedDate == null
                              ? "Pilih tanggal"
                              : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔥 BUTTON KIRIM
                    GestureDetector(
                      onTap: cekData,
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text(
                            "KIRIM",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔥 HASIL
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      color: Colors.grey[300],
                      child: resultData == null
                          ? const Center(child: Text("DETAIL BEROBAT"))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Nama/NIK: ${resultData!['nik']}"),
                                Text("Keluhan: ${resultData!['keluhan']}"),
                                Text("Layanan: ${resultData!['layanan']}"),
                                Text("Status: ${resultData!['status']}"),
                                Text("Tanggal: ${resultData!['tanggal'].toDate()}")
                              ],
                            ),
                    ),

                    const SizedBox(height: 40),

                    const Center(
                      child: Text(
                        "COPYRIGHT BY ....",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// INPUT FIELD
  Widget _inputField({required TextEditingController controller}) {
    return Container(
      height: 50,
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  /// LOGO
  Widget _logo(String text) {
    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image, size: 18, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(text, style: const TextStyle(fontSize: 8)),
      ],
    );
  }
}