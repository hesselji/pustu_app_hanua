import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class RekapanBulananPage extends StatefulWidget {
  const RekapanBulananPage({super.key});

  @override
  State<RekapanBulananPage> createState() => _RekapanBulananPageState();
}

class _RekapanBulananPageState extends State<RekapanBulananPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final List<String> bulanList = const [
    "Januari",
    "Februari",
    "Maret",
    "April",
    "Mei",
    "Juni",
    "Juli",
    "Agustus",
    "September",
    "Oktober",
    "November",
    "Desember",
  ];

  String? selectedBulan;
  int? selectedTahun;

  String? submittedBulan;
  int? submittedTahun;

  bool loading = false;
  bool showResult = false;
  bool noData = false;

  /// 🔥 DATA LAPORAN
  int totalPasien = 0;
  int totalKunjungan = 0;
  int laki = 0;
  int perempuan = 0;

  Map<String, int> umurMap = {
    "Bayi (0–11 bulan)": 0,
    "Anak (1–9 tahun)": 0,
    "Remaja (10–18 tahun)": 0,
    "Pemuda (19–29 tahun)": 0,
    "Dewasa (30–59 tahun)": 0,
    "Lansia (≥60)": 0,
  };

  Map<String, int> penyakitMap = {};

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
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                  _logo(),
                  const SizedBox(width: 6),
                  _logo(),
                  const Spacer(),
                  const Text(
                    "Pustu Hanua",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const Divider(),

            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    const SizedBox(height: 10),

                    const Text(
                      "REKAPAN BULAN",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// FORM
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: selectedBulan,
                              decoration: const InputDecoration(
                                labelText: "Bulan",
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  bulanList.map((e) {
                                    return DropdownMenuItem(
                                      value: e,
                                      child: Text(e),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                setState(() => selectedBulan = val);
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: DropdownButtonFormField<int>(
                              value: selectedTahun,
                              decoration: const InputDecoration(
                                labelText: "Tahun",
                                border: OutlineInputBorder(),
                              ),
                              items:
                                  _tahunList().map((e) {
                                    return DropdownMenuItem(
                                      value: e,
                                      child: Text(e.toString()),
                                    );
                                  }).toList(),
                              onChanged: (val) {
                                setState(() => selectedTahun = val);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: loading ? null : _submitLaporan,
                        child: const Text(
                          "KIRIM",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    if (loading) const CircularProgressIndicator(),

                    if (noData)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Tidak Ada Data Rekapan Bulanan Pada Bulan $submittedBulan Tahun $submittedTahun",
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                    if (showResult) ...[
                      /// TOTAL BOX
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.symmetric(horizontal: 20),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.green[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _rowBetween(
                              "Total Kunjungan Pasien",
                              "$totalKunjungan kunjungan",
                              bold: true,
                            ),

                            const SizedBox(height: 8),

                            _rowBetween(
                              "Total Pasien",
                              "$totalPasien orang",
                              bold: true,
                            ),

                            const SizedBox(height: 12),

                            _barRow(
                              "Laki-laki",
                              laki,
                              totalPasien,
                              Colors.blue,
                            ),

                            _barRow(
                              "Perempuan",
                              perempuan,
                              totalPasien,
                              Colors.pink,
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle("Rentang Umur Pasien"),

                      ...umurMap.entries.map((e) {
                        return _simpleRow(
                          e.key,
                          "${e.value} orang",
                          Colors.orange[100]!,
                        );
                      }),

                      const SizedBox(height: 20),

                      _sectionTitle("Daftar Diagnosis Penyakit"),

                      ...penyakitMap.entries.map((e) {
                        return _simpleRow(
                          e.key,
                          "${e.value} diagnosis",
                          Colors.grey[400]!,
                        );
                      }),
                    ],

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "COPYRIGHT © 2026 PUSTU HANUA",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ===================================================
  /// FIREBASE LOGIC
  /// ===================================================

  Future<void> _submitLaporan() async {
    if (selectedBulan == null || selectedTahun == null) return;

    setState(() {
      submittedBulan = selectedBulan;
      submittedTahun = selectedTahun;
      loading = true;
      showResult = false;
      noData = false;
    });

    if (submittedTahun == 2025) {
      setState(() {
        loading = false;
        noData = true;
      });
      return;
    }

    totalPasien = 0;
    totalKunjungan = 0;
    laki = 0;
    perempuan = 0;

    umurMap.updateAll((key, value) => 0);
    penyakitMap.clear();

    Set<String> pasienUnik = {};

    int bulanAngka = bulanList.indexOf(submittedBulan!) + 1;

    final patients = await firestore.collection("patients").get();

    for (var patient in patients.docs) {
      final data = patient.data();

      String jk = data["jk"] ?? "";
      String tgl = data["tgl"] ?? "";

      bool pasienSudahDihitung = false;

      final medicals =
          await firestore
              .collection("patients")
              .doc(patient.id)
              .collection("medical_records")
              .get();

      for (var med in medicals.docs) {
        final m = med.data();

        if (m["is_deleted"] == true) continue;

        Timestamp? created = m["created_at"];
        if (created == null) continue;

        DateTime dt = created.toDate();

        if (dt.month == bulanAngka && dt.year == submittedTahun) {
          /// total kunjungan
          totalKunjungan++;

          /// pasien unik
          pasienUnik.add(patient.id);

          /// gender + umur hanya sekali per pasien
          if (!pasienSudahDihitung) {
            pasienSudahDihitung = true;

            if (jk.toLowerCase().contains("laki")) {
              laki++;
            } else {
              perempuan++;
            }

            int umur = hitungUmur(tgl);
            kategoriUmur(umur);
          }

          /// diagnosa
          String diagnosa = (m["diagnosa"] ?? "").toString().trim();

          if (diagnosa.isNotEmpty) {
            diagnosa = normalisasiDiagnosa(diagnosa);

            penyakitMap[diagnosa] = (penyakitMap[diagnosa] ?? 0) + 1;
          }
        }
      }
    }

    totalPasien = pasienUnik.length;

    penyakitMap = Map.fromEntries(
      penyakitMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    setState(() {
      loading = false;

      if (totalKunjungan == 0) {
        noData = true;
      } else {
        showResult = true;
      }
    });
  }

  List<int> _tahunList() {
    int now = DateTime.now().year;
    List<int> data = [2025];

    for (int i = 2026; i <= now; i++) {
      data.add(i);
    }

    return data;
  }

  int hitungUmur(String tgl) {
    try {
      List<String> p = tgl.split("-");
      int tahun = int.parse(p[2].trim());
      return DateTime.now().year - tahun;
    } catch (e) {
      return 0;
    }
  }

  void kategoriUmur(int usia) {
    if (usia < 1) {
      umurMap["Bayi (0–11 bulan)"] = umurMap["Bayi (0–11 bulan)"]! + 1;
    } else if (usia <= 9) {
      umurMap["Anak (1–9 tahun)"] = umurMap["Anak (1–9 tahun)"]! + 1;
    } else if (usia <= 18) {
      umurMap["Remaja (10–18 tahun)"] = umurMap["Remaja (10–18 tahun)"]! + 1;
    } else if (usia <= 29) {
      umurMap["Pemuda (19–29 tahun)"] = umurMap["Pemuda (19–29 tahun)"]! + 1;
    } else if (usia <= 59) {
      umurMap["Dewasa (30–59 tahun)"] = umurMap["Dewasa (30–59 tahun)"]! + 1;
    } else {
      umurMap["Lansia (≥60)"] = umurMap["Lansia (≥60)"]! + 1;
    }
  }

  String normalisasiDiagnosa(String text) {
    text = text.trim().toLowerCase();

    if (text.isEmpty) return text;

    return text[0].toUpperCase() + text.substring(1);
  }

  /// ===================================================
  /// UI HELPER
  /// ===================================================

  Widget _rowBetween(String left, String right, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        Text(
          right,
          style: TextStyle(fontWeight: bold ? FontWeight.bold : null),
        ),
      ],
    );
  }

  Widget _barRow(String label, int value, int total, Color color) {
    double percent = total == 0 ? 0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rowBetween(label, "$value orang"),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: percent,
          minHeight: 6,
          backgroundColor: Colors.grey[300],
          color: color,
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _sectionTitle(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),
    );
  }

  Widget _simpleRow(String left, String right, Color bgColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: _rowBetween(left, right),
    );
  }

  Widget _logo() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.image, size: 16),
    );
  }
}
