import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/patient_auth_helper.dart';

class PatientCheckScreen extends StatefulWidget {
  const PatientCheckScreen({super.key});

  @override
  State<PatientCheckScreen> createState() => _PatientCheckScreenState();
}

class _PatientCheckScreenState extends State<PatientCheckScreen> {
  final Color primaryGreen = const Color(0xFF1B7F3A);
  final Color darkGreen = const Color(0xFF0E4D2C);
  final Color background = const Color(0xFFF5F7FA);

  bool isLoadingPatient = true;

  String patientUid = "";
  String patientName = "";
  String patientNik = "";
  String patientPhone = "";

  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    loadPatientData();
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

  Future<void> pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void resetFilterTanggal() {
    setState(() {
      selectedDate = null;
    });
  }

  String formatTanggal(DateTime date) {
    return "${date.day}/${date.month}/${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  String formatTanggalPendek(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  bool isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Colors.orange;
      case "diproses":
        return Colors.blue;
      case "diterima":
        return Colors.green;
      case "selesai":
        return Colors.green;
      case "ditolak":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData statusIcon(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return Icons.hourglass_top_rounded;
      case "diproses":
        return Icons.sync_rounded;
      case "diterima":
        return Icons.check_circle_rounded;
      case "selesai":
        return Icons.verified_rounded;
      case "ditolak":
        return Icons.cancel_rounded;
      default:
        return Icons.info_rounded;
    }
  }

  String statusDescription(String status) {
    switch (status.toLowerCase()) {
      case "pending":
        return "Pendaftaran sedang menunggu konfirmasi petugas.";
      case "diproses":
        return "Pendaftaran sedang diproses oleh petugas.";
      case "diterima":
        return "Pendaftaran diterima. Silakan mengikuti jadwal layanan.";
      case "selesai":
        return "Pelayanan telah selesai dilakukan.";
      case "ditolak":
        return "Pendaftaran ditolak. Silakan hubungi petugas untuk informasi lebih lanjut.";
      default:
        return "Status pendaftaran belum diketahui.";
    }
  }

  List<QueryDocumentSnapshot> filterAndSortRegistrations(
    List<QueryDocumentSnapshot> docs,
  ) {
    final filtered = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      final docPatientUid = data['patient_uid'] ?? '';
      final docNik = data['nik'] ?? '';

      final belongsToCurrentPatient =
          docPatientUid == patientUid || docNik == patientNik;

      if (!belongsToCurrentPatient) return false;

      if (selectedDate == null) return true;

      final tanggalRaw = data['tanggal'];

      if (tanggalRaw is! Timestamp) return false;

      final tanggal = tanggalRaw.toDate();

      return isSameDate(tanggal, selectedDate!);
    }).toList();

    filtered.sort((a, b) {
      final dataA = a.data() as Map<String, dynamic>;
      final dataB = b.data() as Map<String, dynamic>;

      final tglA = dataA['tanggal'];
      final tglB = dataB['tanggal'];

      if (tglA is Timestamp && tglB is Timestamp) {
        return tglB.toDate().compareTo(tglA.toDate());
      }

      return 0;
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
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
                          _patientInfoCard(),

                          const SizedBox(height: 18),

                          _sectionTitle(
                            title: "Status Pendaftaran",
                            subtitle:
                                "Pantau riwayat dan status pendaftaran berobat Anda",
                          ),

                          const SizedBox(height: 14),

                          _filterCard(),

                          const SizedBox(height: 18),

                          _registrationList(),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            darkGreen,
            primaryGreen,
            const Color(0xFF43A047),
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
                  "Cek Status Berobat",
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

  Widget _patientInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
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
                const Text(
                  "Akun Pasien",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                  ),
                ),

                const SizedBox(height: 3),

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
              "Aktif",
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

  Widget _filterCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: const Icon(
                  Icons.filter_alt_rounded,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Filter Tanggal",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Pilih tanggal tertentu atau lihat semua riwayat",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: pilihTanggal,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    height: 54,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.grey.shade200,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.calendar_month_rounded,
                          color: Colors.green,
                        ),

                        const SizedBox(width: 10),

                        Expanded(
                          child: Text(
                            selectedDate == null
                                ? "Semua tanggal"
                                : formatTanggalPendek(selectedDate!),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: selectedDate == null
                                  ? Colors.grey
                                  : Colors.black87,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 10),

              InkWell(
                onTap: resetFilterTanggal,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  height: 54,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.refresh_rounded,
                    color: Colors.red,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _registrationList() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('registrations').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            ),
          );
        }

        final registrations = filterAndSortRegistrations(snapshot.data!.docs);

        if (registrations.isEmpty) {
          return _emptyState();
        }

        return Column(
          children: registrations.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _registrationCard(data);
          }).toList(),
        );
      },
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_late_outlined,
              color: Colors.grey,
              size: 36,
            ),
          ),

          const SizedBox(height: 14),

          const Text(
            "Belum Ada Pendaftaran",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            selectedDate == null
                ? "Anda belum memiliki riwayat pendaftaran berobat."
                : "Tidak ada pendaftaran pada tanggal yang dipilih.",
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.grey,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }

  Widget _registrationCard(Map<String, dynamic> data) {
    final status = data['status'] ?? 'Pending';
    final color = statusColor(status);

    DateTime? tanggal;

    if (data['tanggal'] is Timestamp) {
      tanggal = (data['tanggal'] as Timestamp).toDate();
    }

    final keluhan = data['keluhan'] ?? '-';
    final layanan = data['layanan'] ?? '-';

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: color.withOpacity(0.12),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  statusIcon(status),
                  color: color,
                  size: 30,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: color,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 4),

                    Text(
                      statusDescription(status),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          _detailItem(
            title: "Tanggal Berobat",
            value: tanggal == null ? "-" : formatTanggal(tanggal),
            icon: Icons.calendar_month_rounded,
            color: Colors.green,
          ),

          _detailItem(
            title: "Jenis Layanan",
            value: layanan,
            icon: Icons.local_hospital_rounded,
            color: Colors.blue,
          ),

          _detailItem(
            title: "Keluhan",
            value: keluhan,
            icon: Icons.medical_information_rounded,
            color: Colors.orange,
          ),
        ],
      ),
    );
  }

  Widget _detailItem({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.10),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),

          const SizedBox(width: 12),

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

                const SizedBox(height: 3),

                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle({
    required String title,
    required String subtitle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 3),

        Text(
          subtitle,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}