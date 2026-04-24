import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class WebMedicalRecordScreen extends StatefulWidget {
  const WebMedicalRecordScreen({super.key});

  @override
  State<WebMedicalRecordScreen> createState() =>
      _WebMedicalRecordScreenState();
}

class _WebMedicalRecordScreenState extends State<WebMedicalRecordScreen> {
  String? selectedPatientId;
  String? selectedPatientName;

  DateTime? selectedDate;

  /// 📅 PICK DATE
  Future<void> pickDate() async {
    DateTime now = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  String formatDate(DateTime date) {
    return "${date.day} - ${date.month} - ${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        /// 🔥 LIST PASIEN (LEFT)
        Container(
          width: 280,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.all(12),
                child: Text(
                  "Daftar Pasien",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),

              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("patients")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(
                          child: CircularProgressIndicator());
                    }

                    final docs = snapshot.data!.docs;

                    return ListView.builder(
                      itemCount: docs.length,
                      itemBuilder: (context, i) {
                        final doc = docs[i];
                        final data =
                            doc.data() as Map<String, dynamic>;

                        final active = selectedPatientId == doc.id;

                        return InkWell(
                          onTap: () {
                            setState(() {
                              selectedPatientId = doc.id;
                              selectedPatientName = data['nama'];
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            color: active
                                ? Colors.green.shade50
                                : Colors.transparent,
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(data['nama'] ?? "-",
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold)),
                                Text("NIK ${data['nik']}"),
                              ],
                            ),
                          ),
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

        /// 🔥 RIGHT CONTENT
        Expanded(
          child: selectedPatientId == null
              ? const Center(
                  child: Text("Pilih pasien terlebih dahulu"))
              : Column(
                  children: [
                    /// 🔹 HEADER
                    Row(
                      children: [
                        Text(
                          "Rekam Medis - $selectedPatientName",
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold),
                        ),
                        const Spacer(),

                        ElevatedButton.icon(
                          onPressed: pickDate,
                          icon: const Icon(Icons.date_range),
                          label: Text(selectedDate == null
                              ? "Filter Tanggal"
                              : formatDate(selectedDate!)),
                        ),

                        if (selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.close),
                            onPressed: () {
                              setState(() => selectedDate = null);
                            },
                          )
                      ],
                    ),

                    const SizedBox(height: 20),

                    /// 🔥 TABLE
                    Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection("patients")
                            .doc(selectedPatientId)
                            .collection("medical_records")
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          var docs = snapshot.data!.docs;

                          /// 🔥 SORT DESC BY TANGGAL STRING
                          docs.sort((a, b) {
                            return (b['tanggal'] ?? "")
                                .compareTo(a['tanggal'] ?? "");
                          });

                          /// 🔥 FILTER DATE
                          var filtered = docs.where((doc) {
                            if (selectedDate == null) return true;

                            return doc['tanggal'] ==
                                formatDate(selectedDate!);
                          }).toList();

                          if (filtered.isEmpty) {
                            return const Center(
                                child: Text("Tidak ada data"));
                          }

                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                            ),

                            child: ListView.builder(
                              itemCount: filtered.length,
                              itemBuilder: (context, i) {
                                final d = filtered[i].data()
                                    as Map<String, dynamic>;

                                return Container(
                                  padding: const EdgeInsets.all(15),
                                  margin: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade50,
                                    borderRadius:
                                        BorderRadius.circular(12),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        d['tanggal'] ?? "-",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(height: 5),
                                      Text("Keluhan: ${d['keluhan'] ?? '-'}"),
                                      Text("Diagnosa: ${d['diagnosa'] ?? '-'}"),
                                      Text("Tindakan: ${d['tindakan'] ?? '-'}"),
                                    ],
                                  ),
                                );
                              },
                            ),
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