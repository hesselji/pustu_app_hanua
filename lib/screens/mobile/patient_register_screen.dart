import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/patient_auth_helper.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() =>
      _PatientRegisterScreenState();
}

class _PatientRegisterScreenState extends State<PatientRegisterScreen> {
  final TextEditingController keluhanController = TextEditingController();

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  String selectedLayanan = "";

  bool isLoadingPatient = true;
  bool isSubmitting = false;

  String patientUid = "";
  String patientName = "";
  String patientNik = "";
  String patientPhone = "";

  @override
  void initState() {
    super.initState();
    loadPatientData();
  }

  @override
  void dispose() {
    keluhanController.dispose();
    super.dispose();
  }

  Future<void> loadPatientData() async {
    try {
      final uid = await PatientAuthHelper.getCurrentPatientUid();

      if (uid == null) {
        if (!mounted) return;

        setState(() {
          isLoadingPatient = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Sesi pasien tidak ditemukan. Silakan login ulang."),
            backgroundColor: Colors.red,
          ),
        );

        Navigator.pop(context);
        return;
      }

      final doc = await FirebaseFirestore.instance
          .collection('patient_users')
          .doc(uid)
          .get();

      if (!doc.exists) {
        if (!mounted) return;

        setState(() {
          isLoadingPatient = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Data akun pasien tidak ditemukan."),
            backgroundColor: Colors.red,
          ),
        );

        Navigator.pop(context);
        return;
      }

      final data = doc.data() ?? {};

      if (!mounted) return;

      setState(() {
        patientUid = uid;
        patientName = data['nama'] ?? 'Pasien';
        patientNik = data['nik'] ?? '-';
        patientPhone = data['phone'] ?? '-';
        isLoadingPatient = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoadingPatient = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal memuat data pasien: $e"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

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

  Future<void> kirimData() async {
    FocusScope.of(context).unfocus();

    if (patientUid.isEmpty || patientName.isEmpty || patientNik.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Data akun pasien belum terbaca. Silakan coba lagi."),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (keluhanController.text.trim().isEmpty ||
        selectedDate == null ||
        selectedTime == null ||
        selectedLayanan.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Keluhan, jadwal, dan jenis layanan harus diisi!"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      isSubmitting = true;
    });

    try {
      DateTime finalDateTime = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('registrations').add({
        'patient_uid': patientUid,
        'patient_name': patientName,
        'nik': patientNik,
        'phone': patientPhone,
        'keluhan': keluhanController.text.trim(),
        'tanggal': Timestamp.fromDate(finalDateTime),
        'layanan': selectedLayanan,
        'status': "Pending",
        'is_cleared': false,
        'created_at': Timestamp.now(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Berhasil mendaftar!"),
          backgroundColor: Colors.green,
        ),
      );

      resetForm();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isSubmitting = false;
        });
      }
    }
  }

  void resetForm() {
    setState(() {
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
              _header(),

              Expanded(
                child: isLoadingPatient
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: Colors.green,
                        ),
                      )
                    : SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _serviceStatusCard(),

                            const SizedBox(height: 20),

                            _sectionTitle("Data Pasien"),

                            const SizedBox(height: 12),

                            _patientInfoCard(),

                            const SizedBox(height: 20),

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

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: isSubmitting ? null : kirimData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  disabledBackgroundColor:
                                      Colors.green.withOpacity(0.5),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 16,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(18),
                                  ),
                                ),
                                icon: isSubmitting
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Icon(
                                        Icons.send,
                                        color: Colors.white,
                                      ),
                                label: Text(
                                  isSubmitting
                                      ? "MENGIRIM..."
                                      : "KIRIM PENDAFTARAN",
                                  style: const TextStyle(
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
                                onPressed: isSubmitting ? null : resetForm,
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

  Widget _header() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.green.shade700,
            Colors.green.shade500,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
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

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pendaftaran Berobat",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _serviceStatusCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_status')
          .doc('status')
          .snapshots(),
      builder: (context, snapshot) {
        bool isAvailable = true;

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          isAvailable = data['isAvailable'] ?? true;
        }

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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: isAvailable
                      ? Colors.green.withOpacity(0.12)
                      : Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  isAvailable
                      ? Icons.health_and_safety_rounded
                      : Icons.warning_amber_rounded,
                  color: isAvailable ? Colors.green : Colors.red,
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Status Pelayanan",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      isAvailable
                          ? "Petugas Sedang Tersedia"
                          : "Petugas Tidak Tersedia",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _patientInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: Colors.green.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.person_rounded,
              color: Colors.green,
              size: 30,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  patientName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  "NIK $patientNik",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  "No. Telepon $patientPhone",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              "Akun",
              style: TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

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
                color: value.contains("Pilih") ? Colors.grey : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

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
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected ? Colors.green : Colors.grey.shade300,
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
              color: isSelected ? Colors.white : Colors.green,
            ),

            const SizedBox(height: 8),

            Text(
              text,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}