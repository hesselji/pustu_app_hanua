import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';
import 'package:intl/date_symbol_data_local.dart';

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
  List<String> daftarDiagnosa = [];

  @override
  void initState() {
    super.initState();
    loadDiagnosa();
    initializeDateFormatting('id_ID', null);
  }

  /// 📅 DATE PICKER
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      String formatted = DateFormat("dd MMM yyyy", "id_ID").format(picked);
      setState(() {
        tgl.text = formatted;
      });
    }
  }

  Future<void> loadDiagnosa() async {
    final snapshot =
        await FirebaseFirestore.instance
            .collection("disease_master")
            .orderBy("nama")
            .get();

    setState(() {
      daftarDiagnosa = snapshot.docs.map((e) => e['nama'].toString()).toList();
    });
  }

  Future<void> tambahDiagnosaBaru() async {
    final controller = TextEditingController();

    await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Tambah Diagnosa"),
            content: TextField(
              controller: controller,
              decoration: const InputDecoration(
                hintText: "Masukkan nama penyakit",
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),

              ElevatedButton(
                onPressed: () async {
                  if (controller.text.trim().isEmpty) return;

                  await FirebaseFirestore.instance
                      .collection("disease_master")
                      .add({
                        "nama": controller.text.trim(),
                        "created_at": FieldValue.serverTimestamp(),
                      });

                  Navigator.pop(context);

                  await loadDiagnosa();

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Diagnosa berhasil ditambahkan"),
                    ),
                  );
                },
                child: const Text("Simpan"),
              ),
            ],
          ),
    );
  }

  Future<void> pilihDiagnosa() async {
    final searchController = TextEditingController();

    List<String> filtered = List.from(daftarDiagnosa);

    await showDialog(
      context: context,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text("Pilih Diagnosa"),

              content: SizedBox(
                width: 400,
                height: 450,
                child: Column(
                  children: [
                    /// 🔍 SEARCH
                    TextField(
                      controller: searchController,
                      decoration: InputDecoration(
                        hintText: "Cari penyakit...",
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onChanged: (value) {
                        setModalState(() {
                          filtered =
                              daftarDiagnosa.where((item) {
                                return item.toLowerCase().contains(
                                  value.toLowerCase(),
                                );
                              }).toList();
                        });
                      },
                    ),

                    const SizedBox(height: 15),

                    /// LIST
                    Expanded(
                      child:
                          filtered.isEmpty
                              ? const Center(child: Text("Tidak ada data"))
                              : ListView.builder(
                                itemCount: filtered.length,
                                itemBuilder: (context, index) {
                                  final item = filtered[index];

                                  return Card(
                                    child: ListTile(
                                      title: Text(item),

                                      onTap: () {
                                        diagnosa.text = item;
                                        Navigator.pop(context);
                                      },
                                      trailing: Transform.translate(
                                        offset: const Offset(12, 0),
                                        child: IconButton(
                                          icon: const Icon(
                                            Icons.delete_outline,
                                            color: Colors.red,
                                          ),

                                          onPressed: () async {
                                            bool? confirm = await showDialog(
                                              context: context,
                                              builder:
                                                  (_) => AlertDialog(
                                                    title: const Text(
                                                      "Hapus Diagnosa",
                                                    ),
                                                    content: Text(
                                                      "Yakin ingin menghapus \"$item\" ?",
                                                    ),
                                                    actions: [
                                                      TextButton(
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            context,
                                                            false,
                                                          );
                                                        },
                                                        child: const Text(
                                                          "Batal",
                                                        ),
                                                      ),

                                                      ElevatedButton(
                                                        style:
                                                            ElevatedButton.styleFrom(
                                                              backgroundColor:
                                                                  Colors.red,
                                                            ),
                                                        onPressed: () {
                                                          Navigator.pop(
                                                            context,
                                                            true,
                                                          );
                                                        },
                                                        child: const Text(
                                                          "Hapus",
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            );

                                            if (confirm != true) return;

                                            final snapshot =
                                                await FirebaseFirestore.instance
                                                    .collection(
                                                      "disease_master",
                                                    )
                                                    .where(
                                                      "nama",
                                                      isEqualTo: item,
                                                    )
                                                    .get();

                                            for (var doc in snapshot.docs) {
                                              await doc.reference.delete();
                                            }

                                            await loadDiagnosa();

                                            setModalState(() {
                                              filtered = List.from(
                                                daftarDiagnosa,
                                              );
                                            });

                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              const SnackBar(
                                                content: Text(
                                                  "Diagnosa berhasil dihapus",
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                    ),
                  ],
                ),
              ),

              actions: [
                /// TAMBAH
                ElevatedButton.icon(
                  onPressed: () async {
                    Navigator.pop(context);
                    await tambahDiagnosaBaru();
                  },
                  icon: const Icon(Icons.add),
                  label: const Text("Tambah"),
                ),

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
  Widget input(TextEditingController c, String label, {String? suffix}) {
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
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
              child: AbsorbPointer(child: input(tgl, "Tanggal")),
            ),

            input(keluhan, "Keluhan"),

            /// 🔥 TEKANAN DARAH
            Row(
              children: [
                Expanded(child: input(td1, "Sistolik", suffix: "mmHg")),
                const SizedBox(width: 10),
                Expanded(child: input(td2, "Diastolik", suffix: "mmHg")),
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

            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: GestureDetector(
                onTap: pilihDiagnosa,
                child: AbsorbPointer(
                  child: TextField(
                    controller: diagnosa,
                    decoration: InputDecoration(
                      labelText: "Diagnosa",
                      filled: true,
                      fillColor: Colors.grey[100],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      suffixIcon: const Icon(Icons.arrow_drop_down),
                    ),
                  ),
                ),
              ),
            ),
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
                child:
                    loading
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
