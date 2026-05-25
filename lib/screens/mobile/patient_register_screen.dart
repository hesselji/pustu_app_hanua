import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() =>
      _PatientRegisterScreenState();
}

class _PatientRegisterScreenState
    extends State<PatientRegisterScreen> {

  /// 🔥 CONTROLLER
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController keluhanController =
      TextEditingController();

  /// 🔥 STATE
  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String selectedLayanan = "";

  /// =========================
  /// TIME PICKER
  /// =========================

  Future<void> pilihJam() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  /// =========================
  /// DATE PICKER
  /// =========================

  Future<void> pilihTanggal() async {
    final DateTime today = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: today,
      firstDate: DateTime(
        today.year,
        today.month,
        today.day,
      ),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// =========================
  /// KIRIM DATA
  /// =========================

  Future<void> kirimData() async {
    if (namaController.text.isEmpty ||
        nikController.text.isEmpty ||
        keluhanController.text.isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        selectedLayanan.isEmpty) {

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Semua field harus diisi!"),
          backgroundColor: Colors.red,
        ),
      );

      return;
    }

    try {

      DateTime finalDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await FirebaseFirestore.instance
          .collection('registrations')
          .add({

        'patient_name': namaController.text,
        'nik': nikController.text,
        'keluhan': keluhanController.text,
        'tanggal': Timestamp.fromDate(finalDateTime),
        'layanan': selectedLayanan,
        'status': "Pending",
        'is_cleared': false,
        'created_at': Timestamp.now(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil mendaftar!"),
          backgroundColor: Colors.green,
        ),
      );

      resetForm();

    } catch (e) {

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// =========================
  /// RESET
  /// =========================

  void resetForm() {
    setState(() {
      namaController.clear();
      nikController.clear();
      keluhanController.clear();

      selectedDate = null;
      selectedTime = null;
      selectedLayanan = "";
    });
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

              /// =========================
              /// HEADER
              /// =========================

              Container(
                margin: const EdgeInsets.all(16),

                padding: const EdgeInsets.all(18),

                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.green.shade600,
                      Colors.green.shade400,
                    ],
                  ),

                  borderRadius: BorderRadius.circular(28),

                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.25),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),

                child: Row(
                  children: [

                    /// BACK
                    GestureDetector(
                      onTap: () {
                        Navigator.pop(context);
                      },

                      child: Container(
                        padding: const EdgeInsets.all(10),

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(14),
                        ),

                        child: const Icon(
                          Icons.arrow_back,
                          color: Colors.white,
                        ),
                      ),
                    ),

                    const SizedBox(width: 15),

                    /// LOGO
                    Container(
                      padding: const EdgeInsets.all(10),

                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                      ),

                      child: Image.asset(
                        "assets/logo_pustu.png",
                        width: 40,
                        height: 40,
                      ),
                    ),

                    const SizedBox(width: 15),

                    /// TEXT
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,

                        children: [

                          Text(
                            "Pendaftaran Berobat",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),

                          SizedBox(height: 4),

                          Text(
                            "Pustu Hanua",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              /// =========================
              /// CONTENT
              /// =========================

              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [

                      /// STATUS
                      StreamBuilder<DocumentSnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('service_status')
                            .doc('status')
                            .snapshots(),

                        builder: (context, snapshot) {

                          if (!snapshot.hasData) {
                            return const Center(
                              child: CircularProgressIndicator(),
                            );
                          }

                          final data = snapshot.data!.data()
                              as Map<String, dynamic>?;

                          bool isAvailable =
                              data?['isAvailable'] ?? true;

                          return Container(
                            padding: const EdgeInsets.all(16),

                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),

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
                                  width: 16,
                                  height: 16,

                                  decoration: BoxDecoration(
                                    color: isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                    shape: BoxShape.circle,
                                  ),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Text(
                                    isAvailable
                                        ? "Petugas Sedang Tersedia"
                                        : "Petugas Tidak Tersedia",

                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isAvailable
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 20),

                      /// =========================
                      /// DATA PASIEN
                      /// =========================

                      _sectionTitle("Data Pasien"),

                      const SizedBox(height: 12),

                      _inputField(
                        title: "Nama Pasien",
                        hint: "Masukkan nama lengkap",
                        controller: namaController,
                        icon: Icons.person_outline,
                      ),

                      const SizedBox(height: 16),

                      _inputField(
                        title: "NIK",
                        hint: "Masukkan NIK",
                        controller: nikController,
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                      ),

                      const SizedBox(height: 20),

                      /// =========================
                      /// KELUHAN
                      /// =========================

                      _sectionTitle("Keluhan"),

                      const SizedBox(height: 12),

                      _inputField(
                        title: "Keluhan Pasien",
                        hint: "Tuliskan keluhan pasien",
                        controller: keluhanController,
                        icon: Icons.medical_information_outlined,
                        maxLines: 4,
                      ),

                      const SizedBox(height: 20),

                      /// =========================
                      /// JADWAL
                      /// =========================

                      _sectionTitle("Jadwal Berobat"),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          Expanded(
                            child: _pickerCard(
                              title: "Tanggal",
                              value: selectedDate == null
                                  ? "Pilih tanggal"
                                  : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",

                              icon: Icons.calendar_month,

                              onTap: pilihTanggal,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _pickerCard(
                              title: "Jam",
                              value: selectedTime == null
                                  ? "Pilih jam"
                                  : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",

                              icon: Icons.access_time,

                              onTap: pilihJam,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// =========================
                      /// LAYANAN
                      /// =========================

                      _sectionTitle("Jenis Layanan"),

                      const SizedBox(height: 12),

                      Row(
                        children: [

                          Expanded(
                            child: _layananButton(
                              "Home Care",
                              Icons.home_outlined,
                            ),
                          ),

                          const SizedBox(width: 12),

                          Expanded(
                            child: _layananButton(
                              "Pustu Visit",
                              Icons.local_hospital_outlined,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// =========================
                      /// BUTTON
                      /// =========================

                      SizedBox(
                        width: double.infinity,

                        child: ElevatedButton.icon(
                          onPressed: kirimData,

                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          icon: const Icon(
                            Icons.send,
                            color: Colors.white,
                          ),

                          label: const Text(
                            "KIRIM PENDAFTARAN",

                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      SizedBox(
                        width: double.infinity,

                        child: OutlinedButton.icon(
                          onPressed: resetForm,

                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              vertical: 15,
                            ),

                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(18),
                            ),
                          ),

                          icon: const Icon(Icons.refresh),

                          label: const Text("BERSIHKAN FORM"),
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

  /// =========================
  /// TITLE
  /// =========================

  Widget _sectionTitle(String title) {
    return Text(
      title,

      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// =========================
  /// INPUT
  /// =========================

  Widget _inputField({
    required String title,
    required String hint,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Text(
          title,

          style: const TextStyle(
            fontWeight: FontWeight.w500,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,

          decoration: InputDecoration(
            hintText: hint,

            prefixIcon: Icon(icon),

            filled: true,
            fillColor: Colors.white,

            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(18),
              borderSide: BorderSide.none,
            ),
          ),
        ),
      ],
    );
  }

  /// =========================
  /// PICKER CARD
  /// =========================

  Widget _pickerCard({
    required String title,
    required String value,
    required IconData icon,
    required VoidCallback onTap,
  }) {

    return GestureDetector(
      onTap: onTap,

      child: Container(
        padding: const EdgeInsets.all(16),

        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
            ),
          ],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Row(
              children: [

                Icon(icon, color: Colors.green),

                const SizedBox(width: 8),

                Text(
                  title,

                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              value,

              style: TextStyle(
                color: value.contains("Pilih")
                    ? Colors.grey
                    : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// =========================
  /// BUTTON LAYANAN
  /// =========================

  Widget _layananButton(String text, IconData icon) {

    bool isSelected = selectedLayanan == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLayanan = text;
        });
      },

      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),

        padding: const EdgeInsets.symmetric(
          vertical: 18,
        ),

        decoration: BoxDecoration(
          color: isSelected
              ? Colors.green
              : Colors.white,

          borderRadius: BorderRadius.circular(18),

          border: Border.all(
            color: isSelected
                ? Colors.green
                : Colors.grey.shade300,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 6,
            ),
          ],
        ),

        child: Column(
          children: [

            Icon(
              icon,
              color: isSelected
                  ? Colors.white
                  : Colors.green,
            ),

            const SizedBox(height: 8),

            Text(
              text,

              style: TextStyle(
                color: isSelected
                    ? Colors.white
                    : Colors.black,

                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}