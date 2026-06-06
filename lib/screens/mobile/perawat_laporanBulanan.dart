/*import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:excel/excel.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;*/

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class RekapanBulananPage extends StatefulWidget {
  const RekapanBulananPage({super.key});

  @override
  State<RekapanBulananPage> createState() => _RekapanBulananPageState();
}

class _RekapanBulananPageState extends State<RekapanBulananPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  pw.Widget pdfRow(String label, String value) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.SizedBox(width: 170, child: pw.Text(label)),
        pw.Text(": "),
        pw.Expanded(child: pw.Text(value)),
      ],
    );
  }

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

  /// 🔥 DETAIL POPUP
  Map<String, List<Map<String, dynamic>>> detailKunjungan = {};

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
            /// FORM
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

            /// BUTTON
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
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.picture_as_pdf),
                      label: const Text("PDF"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: exportPDF,
                    ),
                  ),

                  const SizedBox(width: 10),

                  Expanded(
                    child: ElevatedButton.icon(
                      icon: const Icon(Icons.table_chart),
                      label: const Text("Excel"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: exportExcel,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 🔴 TOTAL KUNJUNGAN
              GestureDetector(
                onTap: showDetailKunjungan,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.shade100,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Row(
                            children: [
                              Icon(Icons.touch_app, color: Colors.red),
                              SizedBox(width: 8),
                              Text(
                                "Total Kunjungan",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),

                          Text(
                            "$totalKunjungan kunjungan",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 8),

                      const Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          "Tekan untuk melihat detail pasien",
                          style: TextStyle(fontSize: 12, color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              /// 🟢 TOTAL PASIEN
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  children: [
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

              /// 🟡 RENTANG UMUR
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.orange.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Rentang Umur",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...umurMap.entries.map((e) {
                      return _simpleRow(
                        e.key,
                        "${e.value} orang",
                        Colors.orange.shade50,
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔵 DIAGNOSIS
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Daftar Diagnosis",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    const SizedBox(height: 10),

                    ...penyakitMap.entries.map((e) {
                      return _simpleRow(
                        e.key,
                        "${e.value} diagnosis",
                        Colors.blue.shade50,
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

  /// =========================
  /// FIREBASE
  /// =========================

  Future<void> _submitLaporan() async {
    if (selectedBulan == null || selectedTahun == null) {
      return;
    }

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

    detailKunjungan.clear();

    Set<String> pasienUnik = {};
    Set<String> pasienGenderTerhitung = {};
    Set<String> pasienUmurTerhitung = {};

    int bulanAngka = bulanList.indexOf(submittedBulan!) + 1;

    final snapshot = await firestore.collectionGroup("medical_records").get();

    for (var doc in snapshot.docs) {
      final m = doc.data();

      /// 🔥 SKIP JIKA DIHAPUS
      bool isDeleted = m["is_deleted"] ?? false;

      if (isDeleted == true) continue;

      if (m["tanggal"] == null) continue;

      /// 🔥 PAKAI FIELD TANGGAL
      DateTime? dt = parseTanggal(m["tanggal"]);

      if (dt == null) continue;

      if (dt.month == bulanAngka && dt.year == submittedTahun) {
        totalKunjungan++;

        String pasienId = doc.reference.parent.parent!.id;

        pasienUnik.add(pasienId);

        /// CACHE PASIEN
        if (!cachePasien.containsKey(pasienId)) {
          final pDoc =
              await firestore.collection("patients").doc(pasienId).get();

          if (pDoc.exists) {
            cachePasien[pasienId] = pDoc.data()!;
          }
        }

        final p = cachePasien[pasienId];

        if (p != null) {
          String nama = p["nama"] ?? "-";

          String jk = p["jk"] ?? "";

          String tgl = p["tgl"] ?? "";

          /// DETAIL POPUP
          if (!detailKunjungan.containsKey(nama)) {
            detailKunjungan[nama] = [];
          }

          detailKunjungan[nama]!.add({
            "tanggal": m["tanggal"] ?? "-",
            "diagnosa": m["diagnosa"] ?? "-",
          });

          /// GENDER 1x
          if (!pasienGenderTerhitung.contains(pasienId)) {
            pasienGenderTerhitung.add(pasienId);

            if (jk.toLowerCase().contains("laki")) {
              laki++;
            } else {
              perempuan++;
            }
          }

          /// UMUR 1x
          if (!pasienUmurTerhitung.contains(pasienId)) {
            pasienUmurTerhitung.add(pasienId);

            int umur = hitungUmur(tgl);

            kategoriUmur(umur);
          }
        }

        /// DIAGNOSIS TETAP SEMUA
        String diagnosa = (m["diagnosa"] ?? "").toString().trim();

        if (diagnosa.isNotEmpty) {
          diagnosa = normalisasiDiagnosa(diagnosa);

          penyakitMap[diagnosa] = (penyakitMap[diagnosa] ?? 0) + 1;
        }
      }
    }

    totalPasien = pasienUnik.length;

    /// SORT
    penyakitMap = Map.fromEntries(
      penyakitMap.entries.toList()..sort((a, b) => b.value.compareTo(a.value)),
    );

    setState(() {
      loading = false;
      showResult = totalKunjungan > 0;
      noData = totalKunjungan == 0;
    });
  }

  /// =========================
  /// POPUP DETAIL
  /// =========================

  void showDetailKunjungan() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Daftar Pasien Berobat"),

          content: SizedBox(
            width: double.maxFinite,

            child: SingleChildScrollView(
              child: Column(
                children:
                    detailKunjungan.entries.map((e) {
                      return ExpansionTile(
                        title: Text(
                          e.key,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),

                        children:
                            e.value.map((item) {
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),

                                padding: const EdgeInsets.all(10),

                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,

                                  borderRadius: BorderRadius.circular(10),
                                ),

                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,

                                  children: [
                                    Text("Tanggal : ${item["tanggal"]}"),

                                    Text("Diagnosis : ${item["diagnosa"]}"),
                                  ],
                                ),
                              );
                            }).toList(),
                      );
                    }).toList(),
              ),
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
  }

  /// =========================
  /// UTIL
  /// =========================
  Future<void> exportPDF() async {
    final pdf = pw.Document();

    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,

        build:
            (context) => [
              /// =========================
              /// HEADER
              /// =========================
              pw.Center(
                child: pw.Text(
                  "REKAPAN BULANAN ${submittedBulan!.toUpperCase()} $submittedTahun\n"
                  "PUSKESMAS PEMBANTU (PUSTU) HANUA",
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontSize: 15,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Center(
                child: pw.Text(
                  "Desa Hanua, Kecamatan Banama Tingang,\n"
                  "Kabupaten Pulang Pisau, Provinsi Kalimantan Tengah",
                  textAlign: pw.TextAlign.center,
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),

              pw.SizedBox(height: 8),

              pw.Divider(thickness: 1.5),

              pw.SizedBox(height: 12),

              /// =========================
              /// TOTAL
              /// =========================
              pw.Row(
                children: [
                  pw.SizedBox(
                    width: 170,
                    child: pw.Text(
                      "Total Kunjungan",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  pw.Text(
                    ":",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Text(
                    "$totalKunjungan",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              pw.Row(
                children: [
                  pw.SizedBox(
                    width: 170,
                    child: pw.Text(
                      "Total Pasien",
                      style: pw.TextStyle(
                        fontWeight: pw.FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  pw.Text(
                    ":",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                  pw.SizedBox(width: 5),
                  pw.Text(
                    "$totalPasien",
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),

              pw.SizedBox(height: 12),

              /// =========================
              /// JENIS KELAMIN
              /// =========================
              pw.Text(
                "Jenis Kelamin",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),

              pw.SizedBox(height: 4),

              pdfRow("Laki-laki", "$laki"),
              pdfRow("Perempuan", "$perempuan"),

              pw.SizedBox(height: 12),

              /// =========================
              /// RENTANG UMUR
              /// =========================
              pw.Text(
                "Rentang Umur",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),

              pw.SizedBox(height: 4),

              pdfRow(
                "Bayi (0 s.d 11 Bulan)",
                "${umurMap["Bayi (0–11 bulan)"] ?? 0}",
              ),

              pdfRow(
                "Anak-anak (1 s.d 9 Tahun)",
                "${umurMap["Anak-anak (1–9 tahun)"] ?? 0}",
              ),

              pdfRow(
                "Remaja (10 s.d 18 Tahun)",
                "${umurMap["Remaja (10–18 tahun)"] ?? 0}",
              ),

              pdfRow(
                "Pemuda (19 s.d 29 Tahun)",
                "${umurMap["Pemuda (19–29 tahun)"] ?? 0}",
              ),

              pdfRow(
                "Dewasa (30 s.d 59 Tahun)",
                "${umurMap["Dewasa (30–59 tahun)"] ?? 0}",
              ),

              pdfRow(
                "Lansia (60 Tahun ke Atas)",
                "${umurMap["Lansia (≥60)"] ?? 0}",
              ),

              pw.SizedBox(height: 12),

              /// =========================
              /// DIAGNOSIS
              /// =========================
              pw.Text(
                "Daftar Diagnosis",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),

              pw.SizedBox(height: 5),

              if (penyakitMap.isEmpty)
                pw.Text("Tidak ada data")
              else
                pw.Table(
                  border: pw.TableBorder.all(),
                  columnWidths: {
                    0: const pw.FixedColumnWidth(35),
                    1: const pw.FlexColumnWidth(),
                    2: const pw.FixedColumnWidth(60),
                  },
                  children: [
                    /// HEADER TABEL
                    pw.TableRow(
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            "No",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),

                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            "Diagnosis",
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),

                        pw.Padding(
                          padding: const pw.EdgeInsets.all(5),
                          child: pw.Text(
                            "Jumlah",
                            textAlign: pw.TextAlign.center,
                            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    ...penyakitMap.entries.toList().asMap().entries.map((
                      entry,
                    ) {
                      int no = entry.key + 1;
                      var item = entry.value;

                      return pw.TableRow(
                        children: [
                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              "$no",
                              textAlign: pw.TextAlign.center,
                            ),
                          ),

                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(item.key),
                          ),

                          pw.Padding(
                            padding: const pw.EdgeInsets.all(5),
                            child: pw.Text(
                              "${item.value}",
                              textAlign: pw.TextAlign.center,
                            ),
                          ),
                        ],
                      );
                    }),
                  ],
                ),

              pw.SizedBox(height: 12),

              /// =========================
              /// DETAIL KUNJUNGAN PASIEN
              /// =========================
              pw.Text(
                "Detail Kunjungan Pasien",
                style: pw.TextStyle(
                  fontWeight: pw.FontWeight.bold,
                  fontSize: 12,
                ),
              ),

              if (detailKunjungan.isEmpty)
                pw.Text("Tidak ada data")
              else
                ...detailKunjungan.entries.map(
                  (pasien) => pw.Container(
                    margin: const pw.EdgeInsets.only(bottom: 4),
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          pasien.key,
                          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                        ),

                        ...pasien.value.map(
                          (item) => pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 15),
                            child: pw.Text(
                              "- ${item["tanggal"]} : ${item["diagnosa"]}",
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              pw.SizedBox(height: 25),

              /// =========================
              /// FOOTER TTD
              /// =========================
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Text(
                      "Dicetak pada : "
                      "${now.day}/${now.month}/${now.year}",
                    ),

                    pw.SizedBox(height: 15),

                    pw.Text("Petugas Pustu Hanua"),

                    pw.SizedBox(height: 50),

                    pw.Text("(____________________)"),
                  ],
                ),
              ),
            ],
      ),
    );

    final dir = await getApplicationDocumentsDirectory();

    final file = File("${dir.path}/${getNamaFile()}.pdf");

    await file.writeAsBytes(await pdf.save());

    await OpenFilex.open(file.path);
  }

  Future<void> exportExcel() async {
    var excel = Excel.createExcel();

    /// Gunakan sheet default saja
    String sheetName = excel.getDefaultSheet()!;
    Sheet sheet = excel[sheetName];

    /// Lebar kolom
    sheet.setColumnWidth(0, 45);
    sheet.setColumnWidth(1, 5);
    sheet.setColumnWidth(2, 20);

    final boldStyle = CellStyle(bold: true);

    int row = 0;

    /// =========================
    /// JUDUL
    /// =========================

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
    );

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(
      "REKAPAN BULANAN ${submittedBulan!.toUpperCase()} $submittedTahun",
    );

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .cellStyle = boldStyle;

    row++;

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
    );

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue("PUSKESMAS PEMBANTU (PUSTU) HANUA");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .cellStyle = boldStyle;

    row++;

    sheet.merge(
      CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row),
      CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row),
    );

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(
      "Desa Hanua, Kecamatan Banama Tingang, Kabupaten Pulang Pisau, Provinsi Kalimantan Tengah",
    );

    row += 2;

    /// =========================
    /// TOTAL KUNJUNGAN
    /// =========================

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue("Total Kunjungan");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .cellStyle = boldStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(":");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = IntCellValue(totalKunjungan);

    row++;

    /// =========================
    /// TOTAL PASIEN
    /// =========================

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue("Total Pasien");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .cellStyle = boldStyle;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(":");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = IntCellValue(totalPasien);

    row += 2;

    /// =========================
    /// JENIS KELAMIN
    /// =========================

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue("Jenis Kelamin");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .cellStyle = boldStyle;

    row++;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue("Laki-laki");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(":");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = IntCellValue(laki);

    row++;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue("Perempuan");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
        .value = TextCellValue(":");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
        .value = IntCellValue(perempuan);

    row += 2;

    /// =========================
    /// RENTANG UMUR
    /// =========================

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue("Rentang Umur");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .cellStyle = boldStyle;

    row++;

    final umurData = [
      ["Bayi (0 s.d 11 Bulan)", umurMap["Bayi (0–11 bulan)"] ?? 0],
      ["Anak-anak (1 s.d 9 Tahun)", umurMap["Anak-anak (1–9 tahun)"] ?? 0],
      ["Remaja (10 s.d 18 Tahun)", umurMap["Remaja (10–18 tahun)"] ?? 0],
      ["Pemuda (19 s.d 29 Tahun)", umurMap["Pemuda (19–29 tahun)"] ?? 0],
      ["Dewasa (30 s.d 59 Tahun)", umurMap["Dewasa (30–59 tahun)"] ?? 0],
      ["Lansia (60 Tahun ke Atas)", umurMap["Lansia (≥60)"] ?? 0],
    ];

    for (var item in umurData) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue(item[0].toString());

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
          .value = TextCellValue(":");

      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
          .value = IntCellValue(item[1] as int);

      row++;
    }

    row++;

    /// =========================
    /// DAFTAR DIAGNOSIS
    /// =========================

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue("Daftar Diagnosis");

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .cellStyle = boldStyle;

    row++;

    if (penyakitMap.isEmpty) {
      sheet
          .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
          .value = TextCellValue("Tidak ada data");

      row++;
    } else {
      penyakitMap.forEach((penyakit, jumlah) {
        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
            .value = TextCellValue(penyakit);

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 1, rowIndex: row))
            .value = TextCellValue(":");

        sheet
            .cell(CellIndex.indexByColumnRow(columnIndex: 2, rowIndex: row))
            .value = IntCellValue(jumlah);

        row++;
      });
    }

    row += 2;

    /// =========================
    /// FOOTER
    /// =========================

    final now = DateTime.now();

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue(
      "Dicetak pada : ${now.day}/${now.month}/${now.year}",
    );

    row += 2;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue("Petugas Pustu Hanua");

    row += 4;

    sheet
        .cell(CellIndex.indexByColumnRow(columnIndex: 0, rowIndex: row))
        .value = TextCellValue("(____________________)");

    final dir = await getApplicationDocumentsDirectory();

    final file = File("${dir.path}/${getNamaFile()}.xlsx");

    await file.writeAsBytes(excel.encode()!);

    await OpenFilex.open(file.path);
  }

  String getNamaFile() {
    return "Rekapan_Bulanan_${submittedBulan}_${submittedTahun}";
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

  /// =========================
  /// UI
  /// =========================

  InputDecoration _inputStyle(String label) {
    return InputDecoration(
      labelText: label,
      filled: true,
      fillColor: Colors.grey[100],
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  Widget _rowBetween(String l, String r, {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),

      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [
          Text(l, style: TextStyle(fontWeight: bold ? FontWeight.bold : null)),

          Text(r, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
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
