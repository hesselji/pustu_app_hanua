import 'package:flutter/material.dart';
import 'package:pustu_app_hanua/models/patient_model.dart';
import 'package:pustu_app_hanua/services/patient_controller.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final nik = TextEditingController();
  final nama = TextEditingController();
  final tgl = TextEditingController();
  final alamat = TextEditingController();
  final usia = TextEditingController();
  final pekerjaan = TextEditingController();

  String? jk;
  String? agama;
  String? status;
  String? pendidikan;

  final controller = PatientController();

  bool isLoading = false;

  final jkList = ["Laki-Laki", "Perempuan"];
  final agamaList = ["Islam", "Kristen", "Katolik", "Hindu", "Budha"];
  final statusList = ["Belum Menikah", "Menikah", "Cerai"];
  final pendidikanList = ["SD", "SMP", "SMA", "D3", "S1", "S2"];

  /// 🔥 HITUNG USIA
  void hitungUsia(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    usia.text = age.toString();
  }

  /// 📅 DATE PICKER
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );

    if (picked != null) {
      tgl.text = "${picked.day} - ${picked.month} - ${picked.year}";
      hitungUsia(picked);
    }
  }

  /// 💾 SIMPAN
  Future<void> saveData() async {
    if (nik.text.isEmpty || nama.text.isEmpty || jk == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lengkapi data wajib")),
      );
      return;
    }

    setState(() => isLoading = true);

    await controller.addPatient(
      PatientModel(
        nik: nik.text,
        nama: nama.text,
        jk: jk!,
        tgl: tgl.text,
        alamat: alamat.text,
        agama: agama ?? "",
        pekerjaan: pekerjaan.text,
        pendidikan: pendidikan ?? "",
        status: status ?? "",
        usia: usia.text,
      ),
    );

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Data berhasil ditambahkan")),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      /// 🔝 APPBAR
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Tambah Pasien",
          style: TextStyle(color: Colors.black),
        ),
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
                  setState(() => jk = v);
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
                  setState(() => agama = v);
                }),

                _dropdown("Status", statusList, status, (v) {
                  setState(() => status = v);
                }),

                _dropdown("Pendidikan", pendidikanList, pendidikan, (v) {
                  setState(() => pendidikan = v);
                }),

                _input("Pekerjaan", pekerjaan),
              ],
            ),

            const SizedBox(height: 20),

            /// 🔥 BUTTON
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : saveData,
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
                        "SIMPAN DATA",
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
            child: const Icon(Icons.person_add,
                color: Colors.green, size: 28),
          ),
          const SizedBox(width: 12),
          const Text(
            "Pasien Baru",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
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

  /// 🔹 DROPDOWN (ANTI ERROR)
  Widget _dropdown(
    String label,
    List<String> items,
    String? value,
    Function(String?) onChanged,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: DropdownButtonFormField<String>(
        value: (value != null && items.contains(value)) ? value : null,
        onChanged: onChanged,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
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