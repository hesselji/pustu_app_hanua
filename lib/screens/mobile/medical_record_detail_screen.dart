import 'package:flutter/material.dart';

class MedicalRecordDetailScreen extends StatelessWidget {
  final Map<String, dynamic> data;
  final String tanggal;

  const MedicalRecordDetailScreen({
    super.key,
    required this.data,
    required this.tanggal,
  });

  /// 🔹 COMPONENT ITEM
  Widget item(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontSize: 13, color: Colors.grey)),
          const SizedBox(height: 4),
          Text(
            value.isEmpty ? "-" : value,
            style: const TextStyle(
                fontWeight: FontWeight.w600, fontSize: 15),
          ),
        ],
      ),
    );
  }

  /// 🔥 SAFE GET
  String getVal(String key) {
    return (data[key] ?? "").toString();
  }

  /// 🔥 FORMAT TEKANAN DARAH (FIX UTAMA)
  String getTekananDarah() {
    String sis = getVal("td_sistolik");
    String dias = getVal("td_diastolik");

    if (sis.isEmpty && dias.isEmpty) return "-";
    if (sis.isEmpty) return dias;
    if (dias.isEmpty) return sis;

    return "$sis / $dias mmHg";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        title: Text("Detail $tanggal"),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔹 KELUHAN
              item("Keluhan", getVal("keluhan")),

              const Divider(),

              /// 🔹 TTV
              item("Tekanan Darah", getTekananDarah()),
              item("Nadi", "${getVal("nadi")} x/menit"),
              item("Suhu", "${getVal("suhu")} °C"),

              const Divider(),

              /// 🔹 LAB
              item("Gula Darah", "${getVal("gula_darah")} mg/dL"),
              item("Kolesterol", "${getVal("kolesterol")} mg/dL"),
              item("Asam Urat", "${getVal("asam_urat")} mg/dL"),

              const Divider(),

              /// 🔹 DIAGNOSA
              item("Diagnosa", getVal("diagnosa")),
              item("Terapi", getVal("terapi")),

              const Divider(),

              /// 🔹 ALERGI
              item("Alergi Obat", getVal("alergi_obat")),
              item("Alergi Makanan", getVal("alergi_makanan")),
            ],
          ),
        ),
      ),
    );
  }
}