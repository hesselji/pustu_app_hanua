import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditMedicalRecordScreen extends StatefulWidget {
  final String patientId;
  final String recordId;
  final Map<String, dynamic> data;

  const EditMedicalRecordScreen({
    super.key,
    required this.patientId,
    required this.recordId,
    required this.data,
  });

  @override
  State<EditMedicalRecordScreen> createState() =>
      _EditMedicalRecordScreenState();
}

class _EditMedicalRecordScreenState
    extends State<EditMedicalRecordScreen> {

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

  @override
  void initState() {
    super.initState();

    final d = widget.data;

    tgl.text = d['tanggal'] ?? "";
    keluhan.text = d['keluhan'] ?? "";

    td1.text = d['td_sistolik'] ?? "";
    td2.text = d['td_diastolik'] ?? "";

    nadi.text = d['nadi'] ?? "";
    suhu.text = d['suhu'] ?? "";

    gula.text = d['gula_darah'] ?? "";
    kolesterol.text = d['kolesterol'] ?? "";
    asamUrat.text = d['asam_urat'] ?? "";

    diagnosa.text = d['diagnosa'] ?? "";
    terapi.text = d['terapi'] ?? "";

    alergiObat.text = d['alergi_obat'] ?? "";
    alergiMakanan.text = d['alergi_makanan'] ?? "";
  }

  /// 🔥 VALIDASI ANGKA
  bool isNumber(String val) {
    return val.isEmpty || double.tryParse(val) != null;
  }

  bool validate() {
    if (!isNumber(td1.text) ||
        !isNumber(td2.text) ||
        !isNumber(nadi.text) ||
        !isNumber(suhu.text) ||
        !isNumber(gula.text) ||
        !isNumber(kolesterol.text) ||
        !isNumber(asamUrat.text)) {
      return false;
    }
    return true;
  }

  /// 🔥 UPDATE DATA
  Future<void> updateData() async {
    if (!validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Input angka tidak valid")),
      );
      return;
    }

    setState(() => loading = true);

    await FirebaseFirestore.instance
        .collection("patients")
        .doc(widget.patientId)
        .collection("medical_records")
        .doc(widget.recordId)
        .update({
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
    });

    setState(() => loading = false);

    Navigator.pop(context);
  }

  Widget input(TextEditingController c, String label,
      {TextInputType type = TextInputType.text,
      String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: type,
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
        title: const Text("Edit Rekam Medis"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            input(tgl, "Tanggal"),
            input(keluhan, "Keluhan"),

            Row(
              children: [
                Expanded(
                  child: input(td1, "Sistolik",
                      type: TextInputType.number, suffix: "mmHg"),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: input(td2, "Diastolik",
                      type: TextInputType.number, suffix: "mmHg"),
                ),
              ],
            ),

            input(nadi, "Nadi",
                type: TextInputType.number, suffix: "x/menit"),
            input(suhu, "Suhu",
                type: TextInputType.number, suffix: "°C"),

            const Divider(),

            input(gula, "Gula Darah",
                type: TextInputType.number, suffix: "mg/dL"),
            input(kolesterol, "Kolesterol",
                type: TextInputType.number, suffix: "mg/dL"),
            input(asamUrat, "Asam Urat",
                type: TextInputType.number, suffix: "mg/dL"),

            const Divider(),

            input(diagnosa, "Diagnosa"),
            input(terapi, "Terapi"),

            const Divider(),

            input(alergiObat, "Alergi Obat"),
            input(alergiMakanan, "Alergi Makanan"),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : updateData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: loading
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text("UPDATE"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}