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

  final Map<String, int> bulanMap = {
    "Jan": 1,
    "Feb": 2,
    "Mar": 3,
    "Apr": 4,
    "May": 5,
    "Jun": 6,
    "Jul": 7,
    "Aug": 8,
    "Sep": 9,
    "Oct": 10,
    "Nov": 11,
    "Dec": 12,
  };

  String? selectedBulan;
  int? selectedTahun;

  String? submittedBulan;
  int? submittedTahun;

  bool loading = false;
  bool showResult = false;
  bool noData = false;

  int totalPasien = 0;
  int totalKunjungan = 0;
  int laki = 0;
  int perempuan = 0;

  Map<String, int> umurMap = {
    "Bayi (0–11 bulan)": 0,
    "Anak-anak (1–9 tahun)": 0,
    "Remaja (10–18 tahun)": 0,
    "Pemuda (19–29 tahun)": 0,
    "Dewasa (30–59 tahun)": 0,
    "Lansia (≥60)": 0,
  };

  Map<String, int> penyakitMap = {};

  /// 🔥 CACHE PASIEN
  Map<String, Map<String, dynamic>> cachePasien = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Rekapan Bulanan",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedBulan,
                    decoration: _inputStyle("Bulan"),
                    items:
                        bulanList
                            .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => selectedBulan = val),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedTahun,
                    decoration: _inputStyle("Tahun"),
                    items:
                        _tahunList()
                            .map(
                              (e) => DropdownMenuItem(
                                value: e,
                                child: Text(e.toString()),
                              ),
                            )
                            .toList(),
                    onChanged: (val) => setState(() => selectedTahun = val),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : _submitLaporan,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  "KIRIM",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),

            if (loading) const CircularProgressIndicator(),

            if (noData)
              Text(
                "Tidak ada data pada $submittedBulan $submittedTahun",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),

            if (showResult) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _rowBetween(
                      "Total Kunjungan",
                      "$totalKunjungan kunjungan",
                      bold: true,
                    ),
                    _rowBetween(
                      "Total Pasien",
                      "$totalPasien orang",
                      bold: true,
                    ),
                    const SizedBox(height: 10),
                    _barRow("Laki-laki", laki, totalPasien, Colors.blue),
                    _barRow("Perempuan", perempuan, totalPasien, Colors.pink),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              _sectionTitle("Rentang Umur"),
              ...umurMap.entries.map((e) {
                return _simpleRow(
                  e.key,
                  "${e.value} orang",
                  Colors.orange.shade100,
                );
              }),

              const SizedBox(height: 20),

              _sectionTitle("Daftar Diagnosis"),
              ...penyakitMap.entries.map((e) {
                return _simpleRow(
                  e.key,
                  "${e.value} diagnosis",
                  Colors.grey.shade200,
                );
              }),
            ],
          ],
        ),
      ),
    );
  }

  DateTime? parseTanggal(String text) {
    try {
      List<String> parts = text.split(" ");
      int day = int.parse(parts[0]);
      int month = bulanMap[parts[1]] ?? 0;
      int year = int.parse(parts[2]);

      if (month == 0) return null;

      return DateTime(year, month, day);
    } catch (e) {
      return null;
    }
  }

  /// 🔥 AMBIL DATA CEPAT
  Future<void> _submitLaporan() async {
    if (selectedBulan == null || selectedTahun == null) return;

    setState(() {
      submittedBulan = selectedBulan;
      submittedTahun = selectedTahun;
      loading = true;
      showResult = false;
      noData = false;
    });

    totalPasien = 0;
    totalKunjungan = 0;
    laki = 0;
    perempuan = 0;

    umurMap.updateAll((key, value) => 0);
    penyakitMap.clear();

    Set<String> pasienUnik = {};
    int bulanAngka = bulanList.indexOf(submittedBulan!) + 1;

    /// 🔥 1x QUERY SAJA
    final snapshot = await firestore.collectionGroup("medical_records").get();

    for (var doc in snapshot.docs) {
      final m = doc.data();

      if (m["tanggal"] == null) continue;

      DateTime? dt = parseTanggal(m["tanggal"]);
      if (dt == null) continue;

      if (dt.month == bulanAngka && dt.year == submittedTahun) {
        totalKunjungan++;

        String pasienId = doc.reference.parent.parent!.id;
        pasienUnik.add(pasienId);

        /// 🔥 CACHE PASIEN
        if (!cachePasien.containsKey(pasienId)) {
          final pDoc =
              await firestore.collection("patients").doc(pasienId).get();
          if (pDoc.exists) {
            cachePasien[pasienId] = pDoc.data()!;
          }
        }

        final p = cachePasien[pasienId];
        if (p != null) {
          String jk = p["jk"] ?? "";
          String tgl = p["tgl"] ?? "";

          if (jk.toLowerCase().contains("laki")) {
            laki++;
          } else {
            perempuan++;
          }

          int umur = hitungUmur(tgl);
          kategoriUmur(umur);
        }

        String diagnosa = (m["diagnosa"] ?? "").toString().trim();
        if (diagnosa.isNotEmpty) {
          diagnosa = normalisasiDiagnosa(diagnosa);
          penyakitMap[diagnosa] = (penyakitMap[diagnosa] ?? 0) + 1;
        }
      }
    }

    totalPasien = pasienUnik.length;

    /// 🔥 SORT TERBANYAK
    penyakitMap = Map.fromEntries(
      penyakitMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    setState(() {
      loading = false;
      showResult = totalKunjungan > 0;
      noData = totalKunjungan == 0;
    });
  }

  List<int> _tahunList() {
    int now = DateTime.now().year;
    return [2025, ...List.generate(now - 2025, (i) => 2026 + i)];
  }

  int hitungUmur(String tgl) {
    try {
      return DateTime.now().year - int.parse(tgl.split("-")[2]);
    } catch (_) {
      return 0;
    }
  }

  void kategoriUmur(int usia) {
    if (usia < 1) {
      umurMap["Bayi (0–11 bulan)"] = umurMap["Bayi (0–11 bulan)"]! + 1;
    } else if (usia <= 9) {
      umurMap["Anak-anak (1–9 tahun)"] = umurMap["Anak-anak (1–9 tahun)"]! + 1;
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
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _rowBetween(String l, String r, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(l, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),
        Text(r, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _barRow(String l, int v, int t, Color c) {
    double p = t == 0 ? 0 : v / t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _rowBetween(l, "$v orang"),
        LinearProgressIndicator(value: p, color: c),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _sectionTitle(String t) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        t,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }

  Widget _simpleRow(String l, String r, Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(10),
      ),
      child: _rowBetween(l, r),
    );
  }
}
