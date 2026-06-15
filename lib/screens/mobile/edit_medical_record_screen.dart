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

class _EditMedicalRecordScreenState extends State<EditMedicalRecordScreen> {
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
  String selectedDiagnosaId = "";

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

    selectedDiagnosaId = d['diagnosa_id'] ?? "";
    diagnosa.text = d['diagnosa'] ?? "";
    terapi.text = d['terapi'] ?? "";

    alergiObat.text = d['alergi_obat'] ?? "";
    alergiMakanan.text = d['alergi_makanan'] ?? "";
  }

  @override
  void dispose() {
    tgl.dispose();
    keluhan.dispose();
    td1.dispose();
    td2.dispose();
    nadi.dispose();
    suhu.dispose();
    gula.dispose();
    kolesterol.dispose();
    asamUrat.dispose();
    diagnosa.dispose();
    terapi.dispose();
    alergiObat.dispose();
    alergiMakanan.dispose();
    super.dispose();
  }

  bool isNumber(String val) {
    return val.trim().isEmpty || double.tryParse(val.trim()) != null;
  }

  bool validate() {
    return isNumber(td1.text) &&
        isNumber(td2.text) &&
        isNumber(nadi.text) &&
        isNumber(suhu.text) &&
        isNumber(gula.text) &&
        isNumber(kolesterol.text) &&
        isNumber(asamUrat.text);
  }

  Future<void> pilihDiagnosa() async {
    final searchController = TextEditingController();
    String searchText = "";

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.healing_rounded,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Pilih Diagnosis",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SizedBox(
                width: 400,
                height: 430,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Cari diagnosis...",
                        prefixIcon: const Icon(Icons.search),
                        filled: true,
                        fillColor: const Color(0xFFF5F7FA),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      onChanged: (value) {
                        setModal(() {
                          searchText = value.toLowerCase();
                        });
                      },
                    ),
                    const SizedBox(height: 14),
                    Expanded(
                      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                        stream: FirebaseFirestore.instance
                            .collection("disease_master")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(
                                color: Colors.green,
                              ),
                            );
                          }

                          final docs = snapshot.data!.docs.where((doc) {
                            final data = doc.data();

                            if (data["is_deleted"] == true) return false;

                            final nama =
                                (data["nama"] ?? "").toString().toLowerCase();

                            return nama.contains(searchText);
                          }).toList();

                          docs.sort((a, b) {
                            final namaA = (a.data()["nama"] ?? "")
                                .toString()
                                .toLowerCase();
                            final namaB = (b.data()["nama"] ?? "")
                                .toString()
                                .toLowerCase();

                            return namaA.compareTo(namaB);
                          });

                          if (docs.isEmpty) {
                            return const Center(
                              child: Text(
                                "Diagnosis belum tersedia.\nTambahkan melalui menu Kelola Diagnosis.",
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey),
                              ),
                            );
                          }

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, index) {
                              final doc = docs[index];
                              final data = doc.data();
                              final nama = data["nama"] ?? "-";

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5F7FA),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.medical_information_rounded,
                                    color: Colors.green,
                                  ),
                                  title: Text(
                                    nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedDiagnosaId = doc.id;
                                      diagnosa.text = nama;
                                    });

                                    Navigator.pop(context);
                                  },
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Tutup"),
                ),
              ],
            );
          },
        );
      },
    );


  }

  Future<void> updateData() async {
    if (!validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Input angka tidak valid"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => loading = true);

    try {
      await FirebaseFirestore.instance
          .collection("patients")
          .doc(widget.patientId)
          .collection("medical_records")
          .doc(widget.recordId)
          .update({
        "tanggal": tgl.text.trim(),
        "keluhan": keluhan.text.trim(),
        "td_sistolik": td1.text.trim(),
        "td_diastolik": td2.text.trim(),
        "nadi": nadi.text.trim(),
        "suhu": suhu.text.trim(),
        "gula_darah": gula.text.trim(),
        "kolesterol": kolesterol.text.trim(),
        "asam_urat": asamUrat.text.trim(),
        "diagnosa_id": selectedDiagnosaId,
        "diagnosa": diagnosa.text.trim(),
        "terapi": terapi.text.trim(),
        "alergi_obat": alergiObat.text.trim(),
        "alergi_makanan": alergiMakanan.text.trim(),
        "updated_at": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memperbarui: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => loading = false);
      }
    }
  }

  Widget input(
    TextEditingController c,
    String label, {
    TextInputType type = TextInputType.text,
    String? suffix,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: type,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 6),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }

  Widget diagnosisPicker() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: GestureDetector(
        onTap: pilihDiagnosa,
        child: AbsorbPointer(
          child: TextField(
            controller: diagnosa,
            decoration: InputDecoration(
              labelText: "Diagnosis",
              hintText: "Pilih diagnosis dari daftar",
              filled: true,
              fillColor: Colors.white,
              prefixIcon: const Icon(
                Icons.healing_rounded,
                color: Colors.green,
              ),
              suffixIcon: const Icon(Icons.arrow_drop_down_rounded),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text(
            "Edit Rekam Medis",
            style: TextStyle(color: Colors.black),
          ),
          backgroundColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.black),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              sectionTitle("Data Pemeriksaan"),

              input(tgl, "Tanggal"),
              input(keluhan, "Keluhan", maxLines: 3),

              Row(
                children: [
                  Expanded(
                    child: input(
                      td1,
                      "Sistolik",
                      type: TextInputType.number,
                      suffix: "mmHg",
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: input(
                      td2,
                      "Diastolik",
                      type: TextInputType.number,
                      suffix: "mmHg",
                    ),
                  ),
                ],
              ),

              input(
                nadi,
                "Nadi",
                type: TextInputType.number,
                suffix: "x/menit",
              ),
              input(
                suhu,
                "Suhu",
                type: TextInputType.number,
                suffix: "°C",
              ),

              sectionTitle("Pemeriksaan Laboratorium"),

              input(
                gula,
                "Gula Darah",
                type: TextInputType.number,
                suffix: "mg/dL",
              ),
              input(
                kolesterol,
                "Kolesterol",
                type: TextInputType.number,
                suffix: "mg/dL",
              ),
              input(
                asamUrat,
                "Asam Urat",
                type: TextInputType.number,
                suffix: "mg/dL",
              ),

              sectionTitle("Diagnosis dan Terapi"),

              diagnosisPicker(),
              input(terapi, "Terapi", maxLines: 3),

              sectionTitle("Alergi"),

              input(alergiObat, "Alergi Obat"),
              input(alergiMakanan, "Alergi Makanan"),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: loading ? null : updateData,
                  icon: loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save_rounded, color: Colors.white),
                  label: Text(
                    loading ? "MENYIMPAN..." : "UPDATE",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    disabledBackgroundColor: Colors.blue.withOpacity(0.45),
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}