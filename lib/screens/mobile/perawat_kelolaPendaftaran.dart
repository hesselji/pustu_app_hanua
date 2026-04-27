import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class PerawatKelolaPendaftaranScreen extends StatefulWidget {
  const PerawatKelolaPendaftaranScreen({super.key});

  @override
  State<PerawatKelolaPendaftaranScreen> createState() =>
      _PerawatKelolaPendaftaranScreenState();
}

class _PerawatKelolaPendaftaranScreenState
    extends State<PerawatKelolaPendaftaranScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  DateTime? selectedDate;

  /// 🔥 CONTROLLER BARU
  final TextEditingController tanggalController = TextEditingController();

  bool loading = false;
  bool sudahCari = false;

  List<QueryDocumentSnapshot> daftarPasien = [];

  Map<String, String> cacheNama = {};

  @override
  void dispose() {
    tanggalController.dispose();
    super.dispose();
  }

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Future<String> getNamaDariNIK(String nik) async {
    if (cacheNama.containsKey(nik)) return cacheNama[nik]!;

    final snapshot =
        await firestore
            .collection("patients")
            .where("nik", isEqualTo: nik)
            .limit(1)
            .get();

    if (snapshot.docs.isNotEmpty) {
      String nama =
          (snapshot.docs.first.data()["nama"] ?? "").toString().trim();

      nama = capitalize(nama);

      cacheNama[nik] = nama;
      return nama;
    } else {
      cacheNama[nik] = "(-) Pasien Baru";
      return "(-) Pasien Baru";
    }
  }

  Future<void> pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;

        /// 🔥 SET KE TEXTFIELD
        tanggalController.text = formatTanggal(picked);
      });
    }
  }

  String formatTanggal(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  Future<void> ambilData() async {
    if (selectedDate == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Pilih tanggal dulu")));
      return;
    }

    setState(() {
      loading = true;
      sudahCari = true;
    });

    try {
      final snapshot =
          await firestore
              .collection("registrations")
              .orderBy("created_at", descending: false)
              .get();

      List<QueryDocumentSnapshot> hasil = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        if (data["tanggal"] == null) continue;

        DateTime tgl = (data["tanggal"] as Timestamp).toDate();

        if (tgl.day == selectedDate!.day &&
            tgl.month == selectedDate!.month &&
            tgl.year == selectedDate!.year) {
          hasil.add(doc);
        }
      }

      setState(() {
        daftarPasien = hasil;
        loading = false;
      });
    } catch (e) {
      setState(() => loading = false);
    }
  }

  Future<void> updateStatus(String docId, String statusBaru) async {
    await firestore.collection("registrations").doc(docId).update({
      "status": statusBaru,
    });

    await ambilData();
  }

  Color warnaStatus(String status) {
    switch (status.toLowerCase()) {
      case "diterima":
        return Colors.green;
      case "ditolak":
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  Widget itemDetail(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(width: 90, child: Text(label)),
          const Text(": "),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Kelola Pendaftaran",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// 🔥 FIXED TEXTFIELD
            GestureDetector(
              onTap: pilihTanggal,
              child: AbsorbPointer(
                child: TextField(
                  controller: tanggalController, // 🔥 INI KUNCINYA
                  decoration: InputDecoration(
                    labelText: "Tanggal",
                    hintText: "Pilih tanggal",
                    suffixIcon: const Icon(Icons.calendar_month),
                    filled: true,
                    fillColor: Colors.grey[100],
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: loading ? null : ambilData,
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

            if (sudahCari && !loading)
              daftarPasien.isEmpty
                  ? const Text("Tidak ada pasien")
                  : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: daftarPasien.length,
                    itemBuilder: (context, index) {
                      final doc = daftarPasien[index];
                      final data = doc.data() as Map<String, dynamic>;

                      String id = doc.id;
                      String nik = data["nik"] ?? "-";
                      String keluhan = capitalize(data["keluhan"] ?? "-");
                      String layanan = capitalize(data["layanan"] ?? "-");
                      String status = capitalize(data["status"] ?? "Pending");

                      String jam = "-";
                      String tanggal = "-";

                      if (data["created_at"] != null) {
                        DateTime dt =
                            (data["created_at"] as Timestamp).toDate();
                        jam =
                            "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
                      }

                      if (data["tanggal"] != null) {
                        DateTime dt = (data["tanggal"] as Timestamp).toDate();
                        tanggal = "${dt.day}-${dt.month}-${dt.year}";
                      }

                      return FutureBuilder<String>(
                        future: getNamaDariNIK(nik),
                        builder: (context, snapshot) {
                          String nama = snapshot.data ?? "...";

                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ExpansionTile(
                              collapsedBackgroundColor: Colors.green.shade100,
                              backgroundColor: Colors.green.shade50,
                              title: Text(
                                nik,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Text("Jam daftar : $jam"),
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Column(
                                    children: [
                                      itemDetail("Nama", nama),
                                      itemDetail("NIK", nik),
                                      itemDetail("Keluhan", keluhan),
                                      itemDetail("Layanan", layanan),

                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 90,
                                            child: Text("Status"),
                                          ),
                                          const Text(": "),
                                          Text(
                                            status,
                                            style: TextStyle(
                                              color: warnaStatus(status),
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ],
                                      ),

                                      itemDetail("Tanggal", tanggal),

                                      const SizedBox(height: 15),

                                      Row(
                                        children: [
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed:
                                                  () => updateStatus(
                                                    id,
                                                    "Pending",
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.orange,
                                              ),
                                              child: const Text(
                                                "PENDING",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed:
                                                  () => updateStatus(
                                                    id,
                                                    "Ditolak",
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.red,
                                              ),
                                              child: const Text(
                                                "TOLAK",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 5),
                                          Expanded(
                                            child: ElevatedButton(
                                              onPressed:
                                                  () => updateStatus(
                                                    id,
                                                    "Diterima",
                                                  ),
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor: Colors.green,
                                              ),
                                              child: const Text(
                                                "TERIMA",
                                                style: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }
}
