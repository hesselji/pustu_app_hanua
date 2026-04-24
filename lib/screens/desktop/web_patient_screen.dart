import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebPatientScreen extends StatefulWidget {
  const WebPatientScreen({super.key});

  @override
  State<WebPatientScreen> createState() => _WebPatientScreenState();
}

class _WebPatientScreenState extends State<WebPatientScreen> {
  String search = "";

  final ScrollController verticalController = ScrollController();
  final ScrollController horizontalController = ScrollController();

  /// FORM
  final nama = TextEditingController();
  final nik = TextEditingController();
  final alamat = TextEditingController();
  final tgl = TextEditingController();
  final usia = TextEditingController();
  final pekerjaan = TextEditingController();

  String jk = "Laki-Laki";
  String agama = "Islam";
  String status = "Menikah";
  String pendidikan = "SMA";

  final jkList = ["Laki-Laki", "Perempuan"];
  final agamaList = ["Islam", "Kristen", "Katolik", "Hindu", "Budha"];
  final statusList = ["Belum Menikah", "Menikah", "Cerai"];
  final pendidikanList = ["SD", "SMP", "SMA", "D3", "S1", "S2"];

  /// 🔥 USIA
  void hitungUsia(DateTime birthDate) {
    final now = DateTime.now();
    int age = now.year - birthDate.year;

    if (now.month < birthDate.month ||
        (now.month == birthDate.month && now.day < birthDate.day)) {
      age--;
    }

    usia.text = age.toString();
  }

  /// DATE PICKER
  Future<void> pickDate() async {
    DateTime now = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );

    if (picked != null) {
      tgl.text = "${picked.day} - ${picked.month} - ${picked.year}";
      hitungUsia(picked);
    }
  }

  /// FORM MODAL
  void showForm({String? id, Map<String, dynamic>? data}) {
    if (data != null) {
      nama.text = data['nama'] ?? "";
      nik.text = data['nik'] ?? "";
      alamat.text = data['alamat'] ?? "";
      tgl.text = data['tgl'] ?? "";
      usia.text = data['usia'] ?? "";
      pekerjaan.text = data['pekerjaan'] ?? "";

      jk = data['jk'] ?? jkList.first;
      agama = data['agama'] ?? agamaList.first;
      status = data['status'] ?? statusList.first;
      pendidikan = data['pendidikan'] ?? pendidikanList.first;
    } else {
      nama.clear();
      nik.clear();
      alamat.clear();
      tgl.clear();
      usia.clear();
      pekerjaan.clear();
    }

    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 500,
          padding: const EdgeInsets.all(20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  id == null ? "Tambah Pasien" : "Edit Pasien",
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                _input("Nama", nama),
                _input("NIK", nik),

                _dropdown("Jenis Kelamin", jkList, jk,
                    (v) => setState(() => jk = v!)),

                GestureDetector(
                  onTap: pickDate,
                  child: AbsorbPointer(child: _input("Tanggal Lahir", tgl)),
                ),

                _input("Usia", usia, readOnly: true),
                _input("Alamat", alamat),

                _dropdown("Agama", agamaList, agama,
                    (v) => setState(() => agama = v!)),

                _dropdown("Status", statusList, status,
                    (v) => setState(() => status = v!)),

                _dropdown("Pendidikan", pendidikanList, pendidikan,
                    (v) => setState(() => pendidikan = v!)),

                _input("Pekerjaan", pekerjaan),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: () async {
                    final dataMap = {
                      "nama": nama.text,
                      "nik": nik.text,
                      "jk": jk,
                      "tgl": tgl.text,
                      "usia": usia.text,
                      "alamat": alamat.text,
                      "agama": agama,
                      "status": status,
                      "pendidikan": pendidikan,
                      "pekerjaan": pekerjaan.text,
                    };

                    if (id == null) {
                      await FirebaseFirestore.instance
                          .collection("patients")
                          .add(dataMap);
                    } else {
                      await FirebaseFirestore.instance
                          .collection("patients")
                          .doc(id)
                          .update(dataMap);
                    }

                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                  ),
                  child: const Text("Simpan"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// DELETE
  void delete(String id) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Hapus Pasien"),
        content: const Text("Yakin ingin menghapus data ini?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection("patients")
                  .doc(id)
                  .delete();
              Navigator.pop(context);
            },
            child:
                const Text("Hapus", style: TextStyle(color: Colors.red)),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// HEADER
        Row(
          children: [
            const Text(
              "Data Pasien",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Spacer(),

            Container(
              width: 250,
              height: 45,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (v) => setState(() => search = v.toLowerCase()),
                decoration: const InputDecoration(
                  hintText: "Cari nama...",
                  prefixIcon: Icon(Icons.search),
                  border: InputBorder.none,
                ),
              ),
            ),

            const SizedBox(width: 10),

            ElevatedButton.icon(
              onPressed: () => showForm(),
              icon: const Icon(Icons.add),
              label: const Text("Tambah"),
            )
          ],
        ),

        const SizedBox(height: 20),

        /// 🔥 TABLE CARD
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance
                .collection("patients")
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data!.docs;

              final filtered = docs.where((doc) {
                final nama = doc['nama'].toString().toLowerCase();
                return nama.contains(search);
              }).toList();

              return Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 15,
                    )
                  ],
                ),

                /// 🔥 SCROLLBAR DOUBLE
                child: Scrollbar(
                  controller: verticalController,
                  thumbVisibility: true,
                  interactive: true,
                  child: Scrollbar(
                    controller: horizontalController,
                    thumbVisibility: true,
                    interactive: true,
                    notificationPredicate: (notif) => notif.depth == 1,
                    child: SingleChildScrollView(
                      controller: verticalController,
                      child: SingleChildScrollView(
                        controller: horizontalController,
                        scrollDirection: Axis.horizontal,

                        child: DataTable(
                          columnSpacing: 28,
                          headingRowHeight: 55,
                          dataRowHeight: 55,
                          headingRowColor:
                              WidgetStateProperty.all(Colors.grey.shade100),

                          columns: const [
                            DataColumn(label: Text("Nama")),
                            DataColumn(label: Text("NIK")),
                            DataColumn(label: Text("JK")),
                            DataColumn(label: Text("Tgl")),
                            DataColumn(label: Text("Usia")),
                            DataColumn(label: Text("Alamat")),
                            DataColumn(label: Text("Agama")),
                            DataColumn(label: Text("Status")),
                            DataColumn(label: Text("Pendidikan")),
                            DataColumn(label: Text("Pekerjaan")),
                            DataColumn(label: Text("Aksi")),
                          ],

                          rows: List.generate(filtered.length, (index) {
                            final doc = filtered[index];
                            final d = doc.data() as Map<String, dynamic>;

                            return DataRow(
                              color: WidgetStateProperty.resolveWith<Color?>(
                                (states) => index % 2 == 0
                                    ? Colors.white
                                    : Colors.grey.shade50,
                              ),
                              cells: [
                                DataCell(Text(d['nama'] ?? "-")),
                                DataCell(Text(d['nik'] ?? "-")),
                                DataCell(Text(d['jk'] ?? "-")),
                                DataCell(Text(d['tgl'] ?? "-")),
                                DataCell(Text(d['usia'] ?? "-")),
                                DataCell(Text(d['alamat'] ?? "-")),
                                DataCell(Text(d['agama'] ?? "-")),
                                DataCell(Text(d['status'] ?? "-")),
                                DataCell(Text(d['pendidikan'] ?? "-")),
                                DataCell(Text(d['pekerjaan'] ?? "-")),
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () =>
                                          showForm(id: doc.id, data: d),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () => delete(doc.id),
                                    ),
                                  ],
                                )),
                              ],
                            );
                          }),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _input(String label, TextEditingController c,
      {bool readOnly = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        readOnly: readOnly,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }

  Widget _dropdown(
      String label, List<String> items, String value, Function(String?) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((e) => DropdownMenuItem(value: e, child: Text(e)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(labelText: label),
      ),
    );
  }
}