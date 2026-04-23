import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPatientScreen extends StatefulWidget {
  final String id;
  final Map data;

  const EditPatientScreen({
    super.key,
    required this.id,
    required this.data,
  });

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  late TextEditingController nik;
  late TextEditingController nama;
  late TextEditingController tgl;
  late TextEditingController usia;
  late TextEditingController alamat;
  late TextEditingController pekerjaan;

  String jk = "Laki-Laki";
  String agama = "Islam";
  String status = "Belum Menikah";
  String pendidikan = "SD";

  bool isLoading = false;

  final List<String> jkList = ["Laki-Laki", "Perempuan"];
  final List<String> agamaList = ["Islam", "Kristen", "Katolik", "Hindu", "Budha"];
  final List<String> statusList = ["Belum Menikah", "Menikah", "Cerai"];
  final List<String> pendidikanList = ["SD", "SMP", "SMA", "D3", "S1", "S2"];

  @override
  void initState() {
    super.initState();

    final d = widget.data;

    nik = TextEditingController(text: d['nik'] ?? '');
    nama = TextEditingController(text: d['nama'] ?? '');
    tgl = TextEditingController(text: d['tgl'] ?? '');
    usia = TextEditingController(text: d['usia'] ?? '');
    alamat = TextEditingController(text: d['alamat'] ?? '');
    pekerjaan = TextEditingController(text: d['pekerjaan'] ?? '');

    jk = jkList.contains(d['jk']) ? d['jk'] : jkList.first;
    agama = agamaList.contains(d['agama']) ? d['agama'] : agamaList.first;
    status = statusList.contains(d['status']) ? d['status'] : statusList.first;
    pendidikan = pendidikanList.contains(d['pendidikan'])
        ? d['pendidikan']
        : pendidikanList.first;
  }

  /// 📅 DATE PICKER + AUTO USIA
  Future<void> pickDate() async {
    DateTime now = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now.subtract(const Duration(days: 365 * 20)),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      String formatted = "${picked.day} - ${picked.month} - ${picked.year}";

      int umur = now.year - picked.year;
      if (now.month < picked.month ||
          (now.month == picked.month && now.day < picked.day)) {
        umur--;
      }

      setState(() {
        tgl.text = formatted;
        usia.text = umur.toString();
      });
    }
  }

  /// 🔥 UPDATE
  Future<void> updateData() async {
    setState(() => isLoading = true);

    await FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.id)
        .update({
      'nik': nik.text,
      'nama': nama.text,
      'jk': jk,
      'tgl': tgl.text,
      'usia': usia.text,
      'alamat': alamat.text,
      'agama': agama,
      'status': status,
      'pendidikan': pendidikan,
      'pekerjaan': pekerjaan.text,
    });

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Berhasil diupdate")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Edit Data Pasien",
            style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 HEADER
            _headerCard(),

            const SizedBox(height: 16),

            /// 🔹 DATA UTAMA
            _sectionCard(
              title: "Data Utama",
              children: [
                _input("NIK", nik),
                _input("Nama", nama),

                _dropdown("Jenis Kelamin", jkList, jk, (v) {
                  setState(() => jk = v!);
                }),

                GestureDetector(
                  onTap: pickDate,
                  child: AbsorbPointer(
                    child: _input("Tanggal Lahir", tgl),
                  ),
                ),

                _input("Usia", usia, readOnly: true),
              ],
            ),

            const SizedBox(height: 16),

            /// 🔹 DATA TAMBAHAN
            _sectionCard(
              title: "Informasi Tambahan",
              children: [
                _input("Alamat", alamat),

                _dropdown("Agama", agamaList, agama, (v) {
                  setState(() => agama = v!);
                }),

                _dropdown("Status", statusList, status, (v) {
                  setState(() => status = v!);
                }),

                _dropdown("Pendidikan", pendidikanList, pendidikan, (v) {
                  setState(() => pendidikan = v!);
                }),

                _input("Pekerjaan", pekerjaan),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔥 BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : updateData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "SIMPAN PERUBAHAN",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 HEADER CARD
  Widget _headerCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.green[100],
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.person, color: Colors.green, size: 28),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nama.text.isEmpty ? "-" : nama.text,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        ],
      ),
    );
  }

  /// 🔹 CARD SECTION
  Widget _sectionCard({
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          const SizedBox(height: 10),
          ...children,
        ],
      ),
    );
  }

  /// 🔹 INPUT
  Widget _input(String label, TextEditingController c,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        readOnly: readOnly,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  /// 🔹 DROPDOWN
  Widget _dropdown(
    String label,
    List<String> items,
    String value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: items.contains(value) ? value : items.first,
        onChanged: onChanged,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}