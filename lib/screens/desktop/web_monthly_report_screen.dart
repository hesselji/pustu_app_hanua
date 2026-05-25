import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebMonthlyReportScreen extends StatefulWidget {
  const WebMonthlyReportScreen({super.key});

  @override
  State<WebMonthlyReportScreen> createState() => _WebMonthlyReportScreenState();
}

class _WebMonthlyReportScreenState extends State<WebMonthlyReportScreen> {
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
    "Mei": 5,
    "Jun": 6,
    "Jul": 7,
    "Agu": 8,
    "Sep": 9,
    "Okt": 10,
    "Nov": 11,
    "Des": 12,
  };

  String? selectedBulan;
  int? selectedTahun;

  bool loading = false;
  bool showResult = false;
  bool noData = false;

  int totalPasien = 0;
  int totalKunjungan = 0;
  int laki = 0;
  int perempuan = 0;

  Map<String, int> penyakitMap = {};

  /// 🔥 RENTANG UMUR
  Map<String, int> umurMap = {
    "Bayi (0–11 bulan)": 0,
    "Anak-anak (1–9 tahun)": 0,
    "Remaja (10–18 tahun)": 0,
    "Pemuda (19–29 tahun)": 0,
    "Dewasa (30–59 tahun)": 0,
    "Lansia (≥60)": 0,
  };

  Map<String, Map<String, dynamic>> cachePasien = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            const Text(
              "Laporan Bulanan",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    value: selectedBulan,

                    decoration: _inputStyle("Bulan"),

                    items:
                        bulanList.map((e) {
                          return DropdownMenuItem(value: e, child: Text(e));
                        }).toList(),

                    onChanged: (v) {
                      setState(() => selectedBulan = v);
                    },
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: DropdownButtonFormField<int>(
                    value: selectedTahun,

                    decoration: _inputStyle("Tahun"),

                    items:
                        _tahunList().map((e) {
                          return DropdownMenuItem(
                            value: e,
                            child: Text(e.toString()),
                          );
                        }).toList(),

                    onChanged: (v) {
                      setState(() => selectedTahun = v);
                    },
                  ),
                ),

                const SizedBox(width: 15),

                ElevatedButton.icon(
                  onPressed: loading ? null : _submitLaporan,

                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 18,
                    ),
                  ),

                  icon: const Icon(Icons.analytics),

                  label: const Text("Generate"),
                ),
              ],
            ),

            const SizedBox(height: 25),

            if (loading) const Center(child: CircularProgressIndicator()),

            if (noData)
              const Center(
                child: Text(
                  "Tidak ada data",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

            if (showResult) ...[
              /// TOTAL
              Row(
                children: [
                  Expanded(
                    child: _statCard(
                      "Total Kunjungan",
                      "$totalKunjungan",
                      Colors.red,
                      Icons.monitor_heart,
                    ),
                  ),

                  const SizedBox(width: 15),

                  Expanded(
                    child: _statCard(
                      "Total Pasien",
                      "$totalPasien",
                      Colors.green,
                      Icons.people,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// GENDER
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Jenis Kelamin",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 15),

                    _barRow("Laki-laki", laki, totalPasien, Colors.blue),

                    const SizedBox(height: 15),

                    _barRow("Perempuan", perempuan, totalPasien, Colors.pink),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// RENTANG UMUR
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Rentang Umur",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ...umurMap.entries.map((e) {
                      return _simpleRow(
                        e.key,
                        "${e.value} orang",
                        Colors.orange.shade100,
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// DIAGNOSA
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),

                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                ),

                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,

                  children: [
                    const Text(
                      "Daftar Diagnosis",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),

                    const SizedBox(height: 15),

                    ...penyakitMap.entries.map((e) {
                      return _simpleRow(
                        e.key,
                        "${e.value} diagnosis",
                        Colors.blue.shade100,
                      );
                    }),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 🔥 AMBIL DATA
  Future<void> _submitLaporan() async {
    if (selectedBulan == null || selectedTahun == null) {
      return;
    }

    setState(() {
      loading = true;
      showResult = false;
      noData = false;
    });

    totalPasien = 0;
    totalKunjungan = 0;
    laki = 0;
    perempuan = 0;

    penyakitMap.clear();

    umurMap.updateAll((key, value) => 0);

    Set<String> pasienUnik = {};

    /// 🔥 supaya gender & umur tidak double
    Set<String> pasienSudahDihitung = {};

    int bulanAngka = bulanList.indexOf(selectedBulan!) + 1;

    final snapshot = await firestore.collectionGroup("medical_records").get();

    for (var doc in snapshot.docs) {
      final m = doc.data();

      bool isDeleted = m["is_deleted"] ?? false;

      if (isDeleted == true) continue;

      if (m["tanggal"] == null) continue;

      DateTime? dt = parseTanggal(m["tanggal"]);

      if (dt == null) continue;

      if (dt.month == bulanAngka && dt.year == selectedTahun) {
        totalKunjungan++;

        String pasienId = doc.reference.parent.parent!.id;

        pasienUnik.add(pasienId);

        if (!cachePasien.containsKey(pasienId)) {
          final pDoc =
              await firestore.collection("patients").doc(pasienId).get();

          if (pDoc.exists) {
            cachePasien[pasienId] = pDoc.data()!;
          }
        }

        final p = cachePasien[pasienId];

        /// 🔥 HITUNG HANYA SEKALI PER PASIEN
        if (p != null && !pasienSudahDihitung.contains(pasienId)) {
          pasienSudahDihitung.add(pasienId);

          String jk = (p["jk"] ?? "").toString();

          String tglLahir = (p["tgl"] ?? "").toString();

          int umur = hitungUmurDariTanggal(tglLahir);

          kategoriUmur(umur);

          if (jk.toLowerCase().contains("laki")) {
            laki++;
          } else {
            perempuan++;
          }
        }

        String diagnosa = (m["diagnosa"] ?? "").toString().trim();

        if (diagnosa.isNotEmpty) {
          diagnosa = normalisasiDiagnosa(diagnosa);

          penyakitMap[diagnosa] = (penyakitMap[diagnosa] ?? 0) + 1;
        }
      }
    }

    totalPasien = pasienUnik.length;

    penyakitMap = Map.fromEntries(
      penyakitMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    setState(() {
      loading = false;
      showResult = totalKunjungan > 0;
      noData = totalKunjungan == 0;
    });
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

  int hitungUmurDariTanggal(String text) {
    try {
      List<String> parts = text.split(" - ");

      int day = int.parse(parts[0]);
      int month = int.parse(parts[1]);
      int year = int.parse(parts[2]);

      DateTime birthDate = DateTime(year, month, day);

      DateTime now = DateTime.now();

      int years = now.year - birthDate.year;
      int months = now.month - birthDate.month;

      if (now.day < birthDate.day) {
        months--;
      }

      if (months < 0) {
        years--;
        months += 12;
      }

      /// 🔥 BAYI < 1 TAHUN
      if (years <= 0) {
        return 0;
      }

      return years;
    } catch (e) {
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

  List<int> _tahunList() {
    int now = DateTime.now().year;

    return [2025, ...List.generate(now - 2025, (i) => 2026 + i)];
  }

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _statCard(String title, String value, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(20),

      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(18),
      ),

      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color,
            child: Icon(icon, color: Colors.white),
          ),

          const SizedBox(width: 15),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,

            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),

              Text(title),
            ],
          ),
        ],
      ),
    );
  }

  Widget _barRow(String label, int value, int total, Color color) {
    double p = total == 0 ? 0 : value / total;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,

          children: [Text(label), Text("$value orang")],
        ),

        const SizedBox(height: 6),

        LinearProgressIndicator(value: p, color: color),
      ],
    );
  }

  Widget _simpleRow(String l, String r, Color c) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: c,
        borderRadius: BorderRadius.circular(12),
      ),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(l),
          Text(r, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
