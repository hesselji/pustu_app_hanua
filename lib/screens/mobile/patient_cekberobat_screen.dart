import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientCheckScreen extends StatefulWidget {
  const PatientCheckScreen({super.key});

  @override
  State<PatientCheckScreen> createState() => _PatientCheckScreenState();
}

class _PatientCheckScreenState extends State<PatientCheckScreen> {
  /// 🔥 CONTROLLER
  final TextEditingController nikController = TextEditingController();

  DateTime? selectedDate;
  Map<String, dynamic>? resultData;

  bool isClicked = false;

  /// 🔥 DATE PICKER
  Future<void> pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// 🔥 FORMAT TANGGAL + JAM
  String formatTanggal(DateTime date) {
    return "${date.day}/${date.month}/${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  /// 🔥 CEK DATA
  Future<void> cekData() async {
    setState(() {
      isClicked = true;
    });

    if (nikController.text.isEmpty || selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Isi NIK dan Tanggal terlebih dahulu"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('registrations')
          .where('nik', isEqualTo: nikController.text)
          .get();

      if (snapshot.docs.isEmpty) {
        setState(() {
          resultData = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data tidak ditemukan")),
        );

        return;
      }

      final filtered = snapshot.docs.where((doc) {
        final data = doc.data() as Map<String, dynamic>;

        DateTime tgl = (data['tanggal'] as Timestamp).toDate();

        return tgl.year == selectedDate!.year &&
            tgl.month == selectedDate!.month &&
            tgl.day == selectedDate!.day;
      }).toList();

      if (filtered.isEmpty) {
        setState(() {
          resultData = null;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Data tidak sesuai tanggal")),
        );

        return;
      }

      setState(() {
        resultData = filtered.first.data() as Map<String, dynamic>;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
  }

  /// 🔥 STATUS COLOR
  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;

      case "diproses":
        return Colors.blue;

      case "selesai":
        return Colors.green;

      case "ditolak":
        return Colors.red;

      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },

      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),

        body: SafeArea(
          child: Column(
            children: [
              /// 🔥 HEADER MODERN
              Container(
                margin: const EdgeInsets.all(16),

                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 18,
                ),

                decoration: BoxDecoration(
                  color: Colors.white,

                  borderRadius: BorderRadius.circular(24),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),

                child: Row(
                  children: [
                    /// BACK
                    GestureDetector(
                      onTap: () {
                        FocusScope.of(context).unfocus();
                        Navigator.pop(context);
                      },

                      child: Container(
                        padding: const EdgeInsets.all(10),

                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        child: const Icon(Icons.arrow_back),
                      ),
                    ),

                    const SizedBox(width: 14),

                    /// LOGO
                    Image.asset(
                      "assets/logo_kemenkes.png",
                      width: 45,
                      height: 45,
                    ),

                    const SizedBox(width: 14),

                    /// TEXT
                    const Expanded(
                      child: Column(
                        children: [
                          Text(
                            "Pustu Hanua",
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Layanan Kesehatan",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    /// LOGO
                    Image.asset(
                      "assets/logo_pustu.png",
                      width: 45,
                      height: 45,
                    ),
                  ],
                ),
              ),

              /// CONTENT
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      const SizedBox(height: 5),

                      /// TITLE
                      const Center(
                        child: Column(
                          children: [
                            Text(
                              "LIHAT PENDAFTARAN BEROBAT",
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),

                            SizedBox(height: 6),

                            Text(
                              "Cek status dan detail pendaftaran pasien",
                              style: TextStyle(
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      /// FORM CARD
                      Container(
                        width: double.infinity,

                        padding: const EdgeInsets.all(18),

                        decoration: BoxDecoration(
                          color: Colors.white,

                          borderRadius: BorderRadius.circular(20),

                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 10,
                            ),
                          ],
                        ),

                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,

                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),

                                  decoration: BoxDecoration(
                                    color: Colors.green.shade100,
                                    borderRadius: BorderRadius.circular(12),
                                  ),

                                  child: const Icon(
                                    Icons.search,
                                    color: Colors.green,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                const Text(
                                  "Cari Pendaftaran",
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            /// NIK
                            const Text(
                              "Nomor Induk Kependudukan (NIK)",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 10),

                            _inputField(
                              controller: nikController,
                              hint: "Masukkan NIK pasien",
                              icon: Icons.badge_outlined,
                            ),

                            const SizedBox(height: 20),

                            /// TANGGAL
                            const Text(
                              "Tanggal Berobat",
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            const SizedBox(height: 10),

                            GestureDetector(
                              onTap: pilihTanggal,

                              child: Container(
                                height: 58,

                                padding:
                                    const EdgeInsets.symmetric(horizontal: 14),

                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,

                                  borderRadius: BorderRadius.circular(14),

                                  border: Border.all(
                                    color: Colors.grey.shade300,
                                  ),
                                ),

                                child: Row(
                                  children: [
                                    const Icon(
                                      Icons.calendar_month,
                                      color: Colors.green,
                                    ),

                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Text(
                                        selectedDate == null
                                            ? "Pilih tanggal berobat"
                                            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                                        style: TextStyle(
                                          color: selectedDate == null
                                              ? Colors.grey
                                              : Colors.black87,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 28),

                            /// BUTTON
                            SizedBox(
                              width: double.infinity,

                              height: 52,

                              child: ElevatedButton.icon(
                                onPressed: cekData,

                                style: ElevatedButton.styleFrom(
                                  backgroundColor: isClicked
                                      ? Colors.green
                                      : Colors.green.shade600,

                                  elevation: 0,

                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                ),

                                icon: const Icon(
                                  Icons.search,
                                  color: Colors.white,
                                ),

                                label: const Text(
                                  "CEK PENDAFTARAN",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 28),

                      /// 🔥 RESULT
                      if (resultData != null)
                        Container(
                          width: double.infinity,

                          padding: const EdgeInsets.all(20),

                          decoration: BoxDecoration(
                            color: Colors.white,

                            borderRadius: BorderRadius.circular(22),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.05),
                                blurRadius: 12,
                              ),
                            ],
                          ),

                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,

                            children: [
                              /// HEADER
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),

                                    decoration: BoxDecoration(
                                      color: Colors.green.shade100,
                                      borderRadius: BorderRadius.circular(14),
                                    ),

                                    child: const Icon(
                                      Icons.assignment_turned_in,
                                      color: Colors.green,
                                    ),
                                  ),

                                  const SizedBox(width: 14),

                                  const Expanded(
                                    child: Text(
                                      "Detail Pendaftaran",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 22),

                              /// STATUS CHIP
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),

                                decoration: BoxDecoration(
                                  color: statusColor(
                                    resultData!['status'],
                                  ).withOpacity(0.12),

                                  borderRadius: BorderRadius.circular(12),
                                ),

                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.circle,
                                      size: 12,
                                      color: statusColor(
                                        resultData!['status'],
                                      ),
                                    ),

                                    const SizedBox(width: 10),

                                    Text(
                                      resultData!['status'],
                                      style: TextStyle(
                                        color: statusColor(
                                          resultData!['status'],
                                        ),
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 22),

                              _detailItem(
                                "Nama Pasien",
                                resultData!['patient_name'],
                                Icons.person_outline,
                              ),

                              _detailItem(
                                "NIK",
                                resultData!['nik'],
                                Icons.badge_outlined,
                              ),

                              _detailItem(
                                "Keluhan",
                                resultData!['keluhan'],
                                Icons.medical_information_outlined,
                              ),

                              _detailItem(
                                "Jenis Layanan",
                                resultData!['layanan'],
                                Icons.local_hospital_outlined,
                              ),

                              _detailItem(
                                "Tanggal Berobat",
                                formatTanggal(
                                  (resultData!['tanggal'] as Timestamp)
                                      .toDate(),
                                ),
                                Icons.calendar_month_outlined,
                              ),
                            ],
                          ),
                        ),

                      const SizedBox(height: 30),
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

  /// 🔥 INPUT
  Widget _inputField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),

      child: TextField(
        controller: controller,

        decoration: InputDecoration(
          hintText: hint,

          prefixIcon: Icon(icon, color: Colors.green),

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(vertical: 18),
        ),
      ),
    );
  }

  /// 🔥 DETAIL ITEM
  Widget _detailItem(
    String title,
    String value,
    IconData icon,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),

      padding: const EdgeInsets.all(14),

      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Container(
            padding: const EdgeInsets.all(10),

            decoration: BoxDecoration(
              color: Colors.green.shade100,
              borderRadius: BorderRadius.circular(12),
            ),

            child: Icon(
              icon,
              color: Colors.green,
              size: 20,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}