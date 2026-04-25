import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebMedicalRecordScreen extends StatefulWidget {
  const WebMedicalRecordScreen({super.key});

  @override
  State<WebMedicalRecordScreen> createState() =>
      _WebMedicalRecordScreenState();
}

class _WebMedicalRecordScreenState
    extends State<WebMedicalRecordScreen> {
  String? selectedPatientId;
  String? selectedPatientName;
  DateTime? selectedDate;
  String searchText = "";

  String formatDate(DateTime date) {
    const months = [
      "",
      "Jan","Feb","Mar","Apr","Mei","Jun",
      "Jul","Agu","Sep","Okt","Nov","Des"
    ];
    return "${date.day} ${months[date.month]} ${date.year}";
  }

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (!mounted) return;

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  Widget input(String label, TextEditingController c,
      {String? suffix}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: c,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          suffixText: suffix,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  /// 🔥 DETAIL PREMIUM
  void showDetail(Map<String, dynamic> d) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          width: 580,
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              /// HEADER
              Row(
                children: [
                  const Icon(Icons.medical_services,
                      color: Colors.green),
                  const SizedBox(width: 10),
                  const Text("Detail Rekam Medis",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  )
                ],
              ),

              const Divider(),

              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [

                      _card("Informasi", [
                        _item("Tanggal", d['tanggal']),
                        _item("Keluhan", d['keluhan']),
                        _item("Diagnosa", d['diagnosa']),
                        _item("Terapi", d['terapi']),
                      ]),

                      _card("Vital Sign", [
                        _item("Suhu", "${d['suhu']} °C"),
                        _item("Nadi", "${d['nadi']} x/menit"),
                        _item("TD",
                            "${d['td_sistolik']}/${d['td_diastolik']} mmHg"),
                      ]),

                      _card("Laboratorium", [
                        _item("Gula Darah", "${d['gula_darah']} mg/dL"),
                        _item("Kolesterol", "${d['kolesterol']} mg/dL"),
                        _item("Asam Urat", "${d['asam_urat']} mg/dL"),
                      ]),

                      _card("Alergi", [
                        _item("Obat", d['alergi_obat']),
                        _item("Makanan", d['alergi_makanan']),
                      ]),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _card(String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green)),
          const SizedBox(height: 8),
          ...children
        ],
      ),
    );
  }

  Widget _item(String title, dynamic value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(title)),
          Text(value?.toString() ?? "-",
              style: const TextStyle(fontWeight: FontWeight.w500))
        ],
      ),
    );
  }

  void deleteRecord(String id) {
    final confirm = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi Hapus"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Ketik 'HAPUS' untuk melanjutkan"),
            TextField(controller: confirm),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal")),
          ElevatedButton(
            onPressed: () async {
              if (confirm.text != "HAPUS") return;

              await FirebaseFirestore.instance
                  .collection("patients")
                  .doc(selectedPatientId)
                  .collection("medical_records")
                  .doc(id)
                  .update({
                "is_deleted": true,
                "deleted_at": FieldValue.serverTimestamp(),
              });

              if (!mounted) return;
              Navigator.pop(context);
            },
            child: const Text("Hapus"),
          )
        ],
      ),
    );
  }

  void showForm({String? id, Map<String, dynamic>? data}) {

    String tanggalText = data?['tanggal'] ?? "";

    final keluhan = TextEditingController(text: data?['keluhan']);
    final diagnosa = TextEditingController(text: data?['diagnosa']);
    final terapi = TextEditingController(text: data?['terapi']);

    final suhu = TextEditingController(text: data?['suhu']);
    final nadi = TextEditingController(text: data?['nadi']);
    final tdS = TextEditingController(text: data?['td_sistolik']);
    final tdD = TextEditingController(text: data?['td_diastolik']);

    final gula = TextEditingController(text: data?['gula_darah']);
    final kolesterol = TextEditingController(text: data?['kolesterol']);
    final asam = TextEditingController(text: data?['asam_urat']);

    final alergiObat =
        TextEditingController(text: data?['alergi_obat']);
    final alergiMakanan =
        TextEditingController(text: data?['alergi_makanan']);

    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: StatefulBuilder(
          builder: (context, setModal) {
            return Container(
              width: 520,
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    Text(id == null
                        ? "Tambah Rekam Medis"
                        : "Edit Rekam Medis"),

                    const SizedBox(height: 20),

                    TextField(
                      readOnly: true,
                      controller: TextEditingController(text: tanggalText),
                      decoration: const InputDecoration(
                        labelText: "Tanggal",
                        suffixIcon: Icon(Icons.date_range),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );

                        if (picked != null) {
                          setModal(() {
                            tanggalText = formatDate(picked);
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 10),

                    TextField(controller: keluhan, decoration: const InputDecoration(labelText: "Keluhan")),
                    TextField(controller: diagnosa, decoration: const InputDecoration(labelText: "Diagnosa")),
                    TextField(controller: terapi, decoration: const InputDecoration(labelText: "Terapi")),

                    const Divider(),

                    input("Suhu", suhu, suffix: "°C"),
                    input("Nadi", nadi, suffix: "x/menit"),
                    input("TD Sistolik", tdS, suffix: "mmHg"),
                    input("TD Diastolik", tdD, suffix: "mmHg"),

                    const Divider(),

                    input("Gula Darah", gula, suffix: "mg/dL"),
                    input("Kolesterol", kolesterol, suffix: "mg/dL"),
                    input("Asam Urat", asam, suffix: "mg/dL"),

                    const Divider(),

                    TextField(
                        controller: alergiObat,
                        decoration:
                            const InputDecoration(labelText: "Alergi Obat")),

                    TextField(
                        controller: alergiMakanan,
                        decoration: const InputDecoration(
                            labelText: "Alergi Makanan")),

                    const SizedBox(height: 20),

                    ElevatedButton.icon(
                      onPressed: () async {

                        /// 🔐 KONFIRMASI SIMPAN
                        final confirmController = TextEditingController();

                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Konfirmasi Simpan"),
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text("Ketik 'SIMPAN' untuk melanjutkan"),
                                TextField(controller: confirmController),
                              ],
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context, false),
                                  child: const Text("Batal")),
                              ElevatedButton(
                                onPressed: () {
                                  if (confirmController.text == "SIMPAN") {
                                    Navigator.pop(context, true);
                                  }
                                },
                                child: const Text("Lanjut"),
                              ),
                            ],
                          ),
                        );

                        if (confirm != true) return;

                        final dataMap = {
                          "keluhan": keluhan.text,
                          "diagnosa": diagnosa.text,
                          "terapi": terapi.text,
                          "suhu": suhu.text,
                          "nadi": nadi.text,
                          "td_sistolik": tdS.text,
                          "td_diastolik": tdD.text,
                          "gula_darah": gula.text,
                          "kolesterol": kolesterol.text,
                          "asam_urat": asam.text,
                          "alergi_obat": alergiObat.text,
                          "alergi_makanan": alergiMakanan.text,
                          "tanggal": tanggalText,
                          "is_deleted": false,
                        };

                        if (id == null) {
                          await FirebaseFirestore.instance
                              .collection("patients")
                              .doc(selectedPatientId)
                              .collection("medical_records")
                              .add(dataMap);
                        } else {
                          await FirebaseFirestore.instance
                              .collection("patients")
                              .doc(selectedPatientId)
                              .collection("medical_records")
                              .doc(id)
                              .update(dataMap);
                        }

                        if (!mounted) return;
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.save),
                      label: const Text("Simpan"),
                    )
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 280,
          color: Colors.white,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(10),
                child: TextField(
                  onChanged: (v) =>
                      setState(() => searchText = v.toLowerCase()),
                  decoration: const InputDecoration(
                    hintText: "Cari pasien...",
                    prefixIcon: Icon(Icons.search),
                  ),
                ),
              ),
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("patients")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    var docs = snapshot.data!.docs;

                    docs = docs.where((doc) {
                      final nama =
                          doc['nama'].toString().toLowerCase();
                      return nama.contains(searchText);
                    }).toList();

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final d =
                            docs[i].data() as Map<String, dynamic>;

                        return ListTile(
                          title: Text(d['nama']),
                          subtitle: Text("NIK ${d['nik']}"),
                          onTap: () {
                            setState(() {
                              selectedPatientId = docs[i].id;
                              selectedPatientName = d['nama'];
                            });
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 20),

        Expanded(
          child: selectedPatientId == null
              ? const Center(child: Text("Pilih pasien"))
              : Column(
                  children: [
                    Row(
                      children: [
                        Text("Rekam Medis - $selectedPatientName"),
                        const Spacer(),

                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: pickDate,
                              icon: const Icon(Icons.date_range),
                              label: Text(selectedDate == null
                                  ? "Filter"
                                  : formatDate(selectedDate!)),
                            ),
                            if (selectedDate != null)
                              IconButton(
                                icon: const Icon(Icons.close,
                                    color: Colors.red),
                                onPressed: () {
                                  setState(() => selectedDate = null);
                                },
                              ),
                          ],
                        ),

                        const SizedBox(width: 10),

                        ElevatedButton.icon(
                          onPressed: () => showForm(),
                          icon: const Icon(Icons.add),
                          label: const Text("Tambah"),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("patients")
                            .doc(selectedPatientId)
                            .collection("medical_records")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(child: CircularProgressIndicator());
                          }

                          var docs = snapshot.data!.docs;

                          docs = docs.where((doc) {
                            final d = doc.data() as Map<String, dynamic>;
                            return d['is_deleted'] != true;
                          }).toList();

                          if (selectedDate != null) {
                            final t = formatDate(selectedDate!);
                            docs = docs.where((doc) {
                              return doc['tanggal'] == t;
                            }).toList();
                          }

                          return ListView.builder(
                            itemCount: docs.length,
                            itemBuilder: (context, i) {
                              final doc = docs[i];
                              final d =
                                  doc.data() as Map<String, dynamic>;

                              return Container(
                                margin:
                                    const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius:
                                      BorderRadius.circular(16),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(d['tanggal']),
                                    Text("Keluhan: ${d['keluhan']}"),

                                    Row(
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.visibility),
                                          onPressed: () => showDetail(d),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.edit),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (_) => AlertDialog(
                                                title: const Text("Konfirmasi"),
                                                content: const Text(
                                                    "Yakin ingin edit data ini?"),
                                                actions: [
                                                  TextButton(
                                                      onPressed: () =>
                                                          Navigator.pop(context),
                                                      child: const Text("Batal")),
                                                  ElevatedButton(
                                                    onPressed: () {
                                                      Navigator.pop(context);
                                                      showForm(
                                                          id: doc.id, data: d);
                                                    },
                                                    child:
                                                        const Text("Lanjut"),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () =>
                                              deleteRecord(doc.id),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
                  ],
                ),
        )
      ],
    );
  }
}