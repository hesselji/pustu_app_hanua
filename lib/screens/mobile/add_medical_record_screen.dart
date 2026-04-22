import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final String patientId;

  const AddMedicalRecordScreen({super.key, required this.patientId});

  @override
  State<AddMedicalRecordScreen> createState() =>
      _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState
    extends State<AddMedicalRecordScreen> {

  final tgl = TextEditingController();
  final keluhan = TextEditingController();

  final td1 = TextEditingController();
  final td2 = TextEditingController();

  final nadi = TextEditingController();
  final suhu = TextEditingController();

  final gula = TextEditingController();
  final kolesterol = TextEditingController();
  final asamUrat = TextEditingController();

  final diagnosa = TextEditingController();
  final terapi = TextEditingController();

  final alergiObat = TextEditingController();
  final alergiMakanan = TextEditingController();

  bool loading = false;

  /// 📅 DATE PICKER
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      String formatted = DateFormat("dd MMM yyyy").format(picked);
      setState(() {
        tgl.text = formatted;
      });
    }
  }

  /// 🔥 SAVE DATA
  Future<void> saveData() async {
    if (tgl.text.isEmpty || keluhan.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tanggal & Keluhan wajib diisi")),
      );
      return;
    }

    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection("patients")
        .doc(widget.patientId)
        .collection("medical_records")
        .add({
      "tanggal": tgl.text,
      "keluhan": keluhan.text,

      "td_sistolik": td1.text,
      "td_diastolik": td2.text,

      "nadi": nadi.text,
      "suhu": suhu.text,

      "gula_darah": gula.text,
      "kolesterol": kolesterol.text,
      "asam_urat": asamUrat.text,

      "diagnosa": diagnosa.text,
      "terapi": terapi.text,

      "alergi_obat": alergiObat.text,
      "alergi_makanan": alergiMakanan.text,

      "created_at": FieldValue.serverTimestamp(),
    });

    setState(() => loading = false);

    Navigator.pop(context);
  }

  /// 🔹 INPUT COMPONENT
  Widget input(TextEditingController c, String label,
      {String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: const Text("Tambah Rekam Medis"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            /// 📅 TANGGAL
            GestureDetector(
              onTap: pickDate,
              child: AbsorbPointer(
                child: input(tgl, "Tanggal"),
              ),
            ),

            input(keluhan, "Keluhan"),

            /// 🔥 TEKANAN DARAH
            Row(
              children: [
                Expanded(
                  child: input(td1, "Sistolik", suffix: "mmHg"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: input(td2, "Diastolik", suffix: "mmHg"),
                ),
              ],
            ),

            input(nadi, "Nadi", suffix: "x/menit"),
            input(suhu, "Suhu", suffix: "°C"),

            const Divider(),

            /// 🔬 LAB
            input(gula, "Gula Darah", suffix: "mg/dL"),
            input(kolesterol, "Kolesterol", suffix: "mg/dL"),
            input(asamUrat, "Asam Urat", suffix: "mg/dL"),

            const Divider(),

            input(diagnosa, "Diagnosa"),
            input(terapi, "Terapi"),

            const Divider(),

            input(alergiObat, "Alergi Obat"),
            input(alergiMakanan, "Alergi Makanan"),

            const SizedBox(height: 20),

            /// 💾 BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("SIMPAN"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}