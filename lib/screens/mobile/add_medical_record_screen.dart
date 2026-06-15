import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class AddMedicalRecordScreen extends StatefulWidget {
  final String patientId;

  const AddMedicalRecordScreen({super.key, required this.patientId});

  @override
  State<AddMedicalRecordScreen> createState() => _AddMedicalRecordScreenState();
}

class _AddMedicalRecordScreenState extends State<AddMedicalRecordScreen> {
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

  bool isNumber(String value) {
    return value.trim().isEmpty || double.tryParse(value.trim()) != null;
  }

  Future<void> saveData() async {
    if (tgl.text.trim().isEmpty || keluhan.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Tanggal dan keluhan wajib diisi"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (!isNumber(td1.text) ||
        !isNumber(td2.text) ||
        !isNumber(nadi.text) ||
        !isNumber(suhu.text) ||
        !isNumber(gula.text) ||
        !isNumber(kolesterol.text) ||
        !isNumber(asamUrat.text)) {
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
          .add({
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
        "is_deleted": false,
        "created_at": FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal menyimpan: $e"),
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
    String? suffix,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: c,
        keyboardType: keyboardType,
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
            "Tambah Rekam Medis",
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

              GestureDetector(
                onTap: pickDate,
                child: AbsorbPointer(child: input(tgl, "Tanggal")),
              ),

              input(keluhan, "Keluhan", maxLines: 3),

              Row(
                children: [
                  Expanded(
                    child: input(
                      td1,
                      "Sistolik",
                      suffix: "mmHg",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: input(
                      td2,
                      "Diastolik",
                      suffix: "mmHg",
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),

              input(
                nadi,
                "Nadi",
                suffix: "x/menit",
                keyboardType: TextInputType.number,
              ),
              input(
                suhu,
                "Suhu",
                suffix: "°C",
                keyboardType: TextInputType.number,
              ),

              sectionTitle("Pemeriksaan Laboratorium"),

              input(
                gula,
                "Gula Darah",
                suffix: "mg/dL",
                keyboardType: TextInputType.number,
              ),
              input(
                kolesterol,
                "Kolesterol",
                suffix: "mg/dL",
                keyboardType: TextInputType.number,
              ),
              input(
                asamUrat,
                "Asam Urat",
                suffix: "mg/dL",
                keyboardType: TextInputType.number,
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
                  onPressed: loading ? null : saveData,
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
                    loading ? "MENYIMPAN..." : "SIMPAN",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    disabledBackgroundColor: Colors.green.withOpacity(0.45),
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