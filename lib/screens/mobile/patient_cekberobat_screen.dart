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

  bool isClicked = false; // 🔥 untuk warna tombol

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

  /// 🔥 FORMAT TANGGAL + JAM
  String formatTanggal(DateTime date) {
    return "${date.day}/${date.month}/${date.year} "
           "${date.hour.toString().padLeft(2, '0')}:"
           "${date.minute.toString().padLeft(2, '0')}";
  }

  /// 🔥 CEK DATA KE FIRESTORE (FIX FILTER)
  Future<void> cekData() async {

    setState(() {
      isClicked = true; // tombol jadi hijau
    });

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
          const SnackBar(content: Text("Data tidak ditemukan")),
        );
        return;
      }

      /// 🔥 FILTER TANGGAL (biar sesuai hari yang dipilih)
      final filtered = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;
        DateTime tgl = (data['tanggal'] as Timestamp).toDate();

        return tgl.year == selectedDate!.year &&
               tgl.month == selectedDate!.month &&
               tgl.day == selectedDate!.day;
      }).toList();

      if (filtered.isEmpty) {
        setState(() {
          resultData = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data tidak sesuai tanggal")),
        );
        return;
      }

      setState(() {
        resultData = filtered.first.data() as Map<String, dynamic>;
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

                    /// 🔥 BUTTON KIRIM (HIJAU SAAT DIKLIK)
                    GestureDetector(
                      onTap: cekData,
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          color: isClicked ? Colors.green : Colors.grey[300],
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(
                          child: Text(
                            "KIRIM",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔥 HASIL
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: resultData == null
                          ? const Center(child: Text("DETAIL BEROBAT"))
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Nama: ${resultData!['patient_name']}"),
                                Text("NIK: ${resultData!['nik']}"),
                                const SizedBox(height: 5),
                                Text("Keluhan: ${resultData!['keluhan']}"),
                                Text("Layanan: ${resultData!['layanan']}"),
                                Text("Status: ${resultData!['status']}"),
                                const SizedBox(height: 5),
                                Text(
                                  "Tanggal: ${formatTanggal((resultData!['tanggal'] as Timestamp).toDate())}",
                                ),
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