import 'package:flutter/material.dart';

class RekapanBulananPage extends StatefulWidget {
  const RekapanBulananPage({super.key});

  @override
  State<RekapanBulananPage> createState() => _RekapanBulananPageState();
}

class _RekapanBulananPageState extends State<RekapanBulananPage> {
  final List<String> bulanList = [
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

  /// 🔥 INI KUNCI FIX
  String? submittedBulan;
  int? submittedTahun;

  bool showResult = false;
  bool noData = false;

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
                              decoration: const InputDecoration(
                                labelText: "Bulan",
                                border: OutlineInputBorder(),
                              ),
                              value: selectedBulan,
                              menuMaxHeight: 300,
                              items:
                                  bulanList.map((b) {
                                    return DropdownMenuItem(
                                      value: b,
                                      child: Text(b),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => selectedBulan = value);
                              },
                            ),
                          ),

                          const SizedBox(width: 10),

                          Expanded(
                            child: DropdownButtonFormField<int>(
                              decoration: const InputDecoration(
                                labelText: "Tahun",
                                border: OutlineInputBorder(),
                              ),
                              value: selectedTahun,
                              items:
                                  [2025, 2026].map((year) {
                                    return DropdownMenuItem(
                                      value: year,
                                      child: Text(year.toString()),
                                    );
                                  }).toList(),
                              onChanged: (value) {
                                setState(() => selectedTahun = value);
                              },
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// BUTTON
                    SizedBox(
                      width: 200,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                        onPressed: () {
                          if (selectedBulan != null && selectedTahun != null) {
                            setState(() {
                              /// 🔥 SIMPAN HASIL SUBMIT
                              submittedBulan = selectedBulan;
                              submittedTahun = selectedTahun;

                              if (submittedTahun == 2025) {
                                noData = true;
                                showResult = false;
                              } else {
                                noData = false;
                                showResult = true;
                              }
                            });
                          }
                        },
                        child: const Text(
                          "KIRIM",
                          style: TextStyle(color: Colors.black),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// ❌ NO DATA
                    if (noData)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          "Tidak Ada Data Rekapan Bulanan Pada Bulan $submittedBulan Tahun $submittedTahun",
                          style: const TextStyle(color: Colors.red),
                          textAlign: TextAlign.center,
                        ),
                      ),

                    /// ✅ RESULT
                    if (showResult) ...[
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
                            _rowBetween("Total Pasien", "35 orang", bold: true),
                            const SizedBox(height: 10),

                            _barRow("Laki-laki", 20, 35, Colors.blue),
                            _barRow("Perempuan", 15, 35, Colors.pink),
                          ],
                        ),
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle("Rentang Umur Pasien"),

                      _simpleRow(
                        "Bayi (0–11 bulan)",
                        "5 orang",
                        Colors.orange[100]!,
                      ),
                      _simpleRow(
                        "Anak (1–9 tahun)",
                        "10 orang",
                        Colors.orange[100]!,
                      ),
                      _simpleRow(
                        "Remaja (10–18 tahun)",
                        "7 orang",
                        Colors.orange[100]!,
                      ),
                      _simpleRow(
                        "Pemuda (19–29 tahun)",
                        "6 orang",
                        Colors.orange[100]!,
                      ),
                      _simpleRow(
                        "Dewasa (30–59 tahun)",
                        "5 orang",
                        Colors.orange[100]!,
                      ),
                      _simpleRow(
                        "Lansia (≥60)",
                        "2 orang",
                        Colors.orange[100]!,
                      ),

                      const SizedBox(height: 20),

                      _sectionTitle("Daftar Penyakit / Perawatan"),

                      _simpleRow("ISPA", "5 orang", Colors.grey[400]!),
                      _simpleRow("Demam", "3 orang", Colors.grey[400]!),
                      _simpleRow("Hipertensi", "4 orang", Colors.grey[400]!),
                      _simpleRow("Diare", "1 orang", Colors.grey[400]!),
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
    double percent = value / total;

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
