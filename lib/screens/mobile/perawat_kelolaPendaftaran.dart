import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../services/notification_api_service.dart';

class PerawatKelolaPendaftaranScreen extends StatefulWidget {
  const PerawatKelolaPendaftaranScreen({super.key});

  @override
  State<PerawatKelolaPendaftaranScreen> createState() =>
      _PerawatKelolaPendaftaranScreenState();
}

class _PerawatKelolaPendaftaranScreenState
    extends State<PerawatKelolaPendaftaranScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Color primaryGreen = const Color(0xFF1B7F3A);
  final Color darkGreen = const Color(0xFF0E4D2C);
  final Color background = const Color(0xFFF5F7FA);

  DateTime selectedDate = DateTime.now();
  bool isUpdating = false;

  Map<String, bool> cachePasienTerdaftar = {};

  String capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> registrationStream() {
    final start = DateTime(
      selectedDate.year,
      selectedDate.month,
      selectedDate.day,
    );

    final end = start.add(const Duration(days: 1));

    return firestore
        .collection("registrations")
        .where(
          "tanggal",
          isGreaterThanOrEqualTo: Timestamp.fromDate(start),
        )
        .where(
          "tanggal",
          isLessThan: Timestamp.fromDate(end),
        )
        .snapshots();
  }

  Future<bool> cekPasienTerdaftar(String nik) async {
    if (cachePasienTerdaftar.containsKey(nik)) {
      return cachePasienTerdaftar[nik]!;
    }

    final snapshot = await firestore
        .collection("patients")
        .where("nik", isEqualTo: nik)
        .limit(1)
        .get();

    final terdaftar = snapshot.docs.isNotEmpty;

    cachePasienTerdaftar[nik] = terdaftar;

    return terdaftar;
  }

  Future<String?> getPatientFcmToken(Map<String, dynamic> data) async {
    final patientUid = data["patient_uid"] ?? "";
    final nik = data["nik"] ?? "";

    if (patientUid.toString().isNotEmpty) {
      final doc =
          await firestore.collection("patient_users").doc(patientUid).get();

      if (doc.exists) {
        final patientData = doc.data() ?? {};
        final token = patientData["fcm_token"];

        if (token != null && token.toString().isNotEmpty) {
          return token.toString();
        }
      }
    }

    if (nik.toString().isNotEmpty) {
      final query = await firestore
          .collection("patient_users")
          .where("nik", isEqualTo: nik)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final token = query.docs.first.data()["fcm_token"];

        if (token != null && token.toString().isNotEmpty) {
          return token.toString();
        }
      }
    }

    return null;
  }

  Future<void> pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  void keHariIni() {
    setState(() {
      selectedDate = DateTime.now();
    });
  }

  String formatTanggal(DateTime date) {
    return "${date.day}/${date.month}/${date.year}";
  }

  String formatJam(DateTime date) {
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
  }

  String formatTanggalJam(DateTime date) {
    return "${formatTanggal(date)} ${formatJam(date)}";
  }

  Color warnaStatus(String status) {
    switch (status.toLowerCase()) {
      case "diterima":
        return Colors.green;
      case "ditolak":
        return Colors.red;
      case "diproses":
        return Colors.blue;
      case "selesai":
        return Colors.teal;
      default:
        return Colors.orange;
    }
  }

  IconData iconStatus(String status) {
    switch (status.toLowerCase()) {
      case "diterima":
        return Icons.check_circle_rounded;
      case "ditolak":
        return Icons.cancel_rounded;
      case "diproses":
        return Icons.sync_rounded;
      case "selesai":
        return Icons.verified_rounded;
      default:
        return Icons.hourglass_top_rounded;
    }
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> sortRegistrations(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final sorted = [...docs];

    sorted.sort((a, b) {
      final dataA = a.data();
      final dataB = b.data();

      final tanggalA = dataA["tanggal"];
      final tanggalB = dataB["tanggal"];

      if (tanggalA is Timestamp && tanggalB is Timestamp) {
        return tanggalA.toDate().compareTo(tanggalB.toDate());
      }

      return 0;
    });

    return sorted;
  }

  int countStatus(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
    String status,
  ) {
    return docs.where((doc) {
      final data = doc.data();
      final currentStatus = data["status"] ?? "Pending";
      return currentStatus.toString().toLowerCase() == status.toLowerCase();
    }).length;
  }

  Future<void> updateStatus({
    required String docId,
    required Map<String, dynamic> data,
    required String statusBaru,
  }) async {
    final statusLama = data["status"] ?? "Pending";

    if (statusLama.toString().toLowerCase() == statusBaru.toLowerCase()) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status sudah $statusBaru"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      await firestore.collection("registrations").doc(docId).update({
        "status": statusBaru,
        "status_updated_at": FieldValue.serverTimestamp(),
        "status_updated_by_email": user?.email,
        "status_updated_by_uid": user?.uid,
      });

      if (statusBaru == "Diterima" || statusBaru == "Ditolak") {
        await kirimNotifikasiStatusKePasien(
          docId: docId,
          data: data,
          statusBaru: statusBaru,
        );
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Status berhasil diubah menjadi $statusBaru"),
          backgroundColor: warnaStatus(statusBaru),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Gagal mengubah status: $e"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  Future<void> kirimNotifikasiStatusKePasien({
    required String docId,
    required Map<String, dynamic> data,
    required String statusBaru,
  }) async {
    try {
      final token = await getPatientFcmToken(data);

      if (token == null) {
        debugPrint("Token FCM pasien tidak ditemukan");
        return;
      }

      final nama = data["patient_name"] ?? "Pasien";
      final layanan = data["layanan"] ?? "layanan berobat";
      final tanggalRaw = data["tanggal"];

      String tanggalText = "-";

      if (tanggalRaw is Timestamp) {
        tanggalText = formatTanggalJam(tanggalRaw.toDate());
      }

      final title = statusBaru == "Diterima"
          ? "Pendaftaran Berobat Diterima"
          : "Pendaftaran Berobat Ditolak";

      final body = statusBaru == "Diterima"
          ? "$nama, pendaftaran $layanan pada $tanggalText telah diterima oleh petugas."
          : "$nama, pendaftaran $layanan pada $tanggalText ditolak. Silakan hubungi petugas untuk informasi lebih lanjut.";

      await NotificationApiService.sendToPatientToken(
        token: token,
        title: title,
        body: body,
        data: {
          "type": "registration_status",
          "registration_id": docId,
          "status": statusBaru,
          "patient_uid": data["patient_uid"] ?? "",
          "nik": data["nik"] ?? "",
        },
      );
    } catch (e) {
      debugPrint("Gagal mengirim notifikasi status ke pasien: $e");
    }
  }

  Future<void> konfirmasiStatus({
    required String docId,
    required Map<String, dynamic> data,
    required String statusBaru,
  }) async {
    final color = warnaStatus(statusBaru);
    final icon = iconStatus(statusBaru);

    final bool? confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Ubah ke $statusBaru?",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            statusBaru == "Diterima"
                ? "Pendaftaran pasien akan diterima dan notifikasi akan dikirim ke pasien."
                : statusBaru == "Ditolak"
                    ? "Pendaftaran pasien akan ditolak dan notifikasi akan dikirim ke pasien."
                    : "Status pendaftaran akan diubah menjadi $statusBaru.",
            style: const TextStyle(height: 1.4),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: color,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Ya",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirm == true) {
      await updateStatus(
        docId: docId,
        data: data,
        statusBaru: statusBaru,
      );
    }
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
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: registrationStream(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Colors.green,
                      ),
                    );
                  }

                  final docs = sortRegistrations(snapshot.data!.docs);

                  return SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _filterTanggalCard(),

                        const SizedBox(height: 18),

                        _statistikSection(docs),

                        const SizedBox(height: 22),

                        _sectionTitle(
                          title: "Daftar Pendaftaran",
                          subtitle:
                              "Kelola konfirmasi pasien berdasarkan tanggal layanan",
                        ),

                        const SizedBox(height: 14),

                        if (docs.isEmpty)
                          _emptyState()
                        else
                          Column(
                            children: docs.map((doc) {
                              return _registrationCard(doc);
                            }).toList(),
                          ),

                        const SizedBox(height: 30),
                      ],
                    ),
                  );
                },
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
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
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
                  "Kelola Pendaftaran",
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
                  "Konfirmasi layanan pasien",
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

  Widget _filterTanggalCard() {
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
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.calendar_month_rounded,
              color: Colors.green,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: InkWell(
              onTap: pilihTanggal,
              borderRadius: BorderRadius.circular(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Tanggal Layanan",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    formatTanggal(selectedDate),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          OutlinedButton(
            onPressed: keHariIni,
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.green,
              side: BorderSide(
                color: Colors.green.withOpacity(0.4),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            child: const Text(
              "Hari Ini",
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _statistikSection(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final total = docs.length;
    final pending = countStatus(docs, "Pending");
    final diterima = countStatus(docs, "Diterima");
    final ditolak = countStatus(docs, "Ditolak");

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle(
          title: "Ringkasan",
          subtitle: "Statistik pendaftaran pada tanggal yang dipilih",
        ),

        const SizedBox(height: 14),

        Row(
          children: [
            Expanded(
              child: _statCard(
                title: "Total",
                value: total.toString(),
                icon: Icons.assignment_rounded,
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                title: "Pending",
                value: pending.toString(),
                icon: Icons.hourglass_top_rounded,
                color: Colors.orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),

        Row(
          children: [
            Expanded(
              child: _statCard(
                title: "Diterima",
                value: diterima.toString(),
                icon: Icons.check_circle_rounded,
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _statCard(
                title: "Ditolak",
                value: ditolak.toString(),
                icon: Icons.cancel_rounded,
                color: Colors.red,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _statCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      height: 125,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -8,
            child: Icon(
              icon,
              size: 58,
              color: color.withOpacity(0.08),
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 22,
                ),
              ),

              const Spacer(),

              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),

              const SizedBox(height: 2),

              Text(
                title,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _registrationCard(
    QueryDocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data();

    final id = doc.id;
    final nik = data["nik"] ?? "-";
    final nama = capitalize(data["patient_name"] ?? "-");
    final keluhan = data["keluhan"] ?? "-";
    final layanan = data["layanan"] ?? "-";
    final status = data["status"] ?? "Pending";
    final phone = data["phone"] ?? "-";

    String jamDaftar = "-";
    String tanggalBerobat = "-";
    String jamBerobat = "-";

    if (data["created_at"] is Timestamp) {
      final dt = (data["created_at"] as Timestamp).toDate();
      jamDaftar = formatJam(dt);
    }

    if (data["tanggal"] is Timestamp) {
      final dt = (data["tanggal"] as Timestamp).toDate();
      tanggalBerobat = formatTanggal(dt);
      jamBerobat = formatJam(dt);
    }

    final statusColor = warnaStatus(status);

    return FutureBuilder<bool>(
      future: cekPasienTerdaftar(nik),
      builder: (context, snapshot) {
        final pasienTerdaftar = snapshot.data ?? false;

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(bottom: 14),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: statusColor.withOpacity(0.12),
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
                      color: statusColor.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Icon(
                      iconStatus(status),
                      color: statusColor,
                      size: 30,
                    ),
                  ),

                  const SizedBox(width: 14),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          nama,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          "Jam daftar $jamDaftar • $layanan",
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

                  _statusChip(status),
                ],
              ),

              const SizedBox(height: 14),

              Row(
                children: [
                  _patientTypeChip(
                    pasienTerdaftar ? "Pasien Terdaftar" : "Pasien Baru",
                    pasienTerdaftar ? Colors.green : Colors.orange,
                  ),
                  const SizedBox(width: 8),
                  _patientTypeChip(
                    layanan.toString(),
                    Colors.blue,
                  ),
                ],
              ),

              const SizedBox(height: 14),

              _detailItem(
                title: "NIK",
                value: nik,
                icon: Icons.badge_rounded,
                color: Colors.green,
              ),

              _detailItem(
                title: "No. Telepon",
                value: phone,
                icon: Icons.phone_android_rounded,
                color: Colors.blue,
              ),

              _detailItem(
                title: "Keluhan",
                value: keluhan.toString(),
                icon: Icons.medical_information_rounded,
                color: Colors.orange,
              ),

              _detailItem(
                title: "Jadwal Berobat",
                value: "$tanggalBerobat • $jamBerobat",
                icon: Icons.calendar_month_rounded,
                color: Colors.deepPurple,
              ),

              const SizedBox(height: 10),

              _actionButtons(
                docId: id,
                data: data,
                currentStatus: status,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statusChip(String status) {
    final color = warnaStatus(status);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: color.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    );
  }

  Widget _patientTypeChip(String text, Color color) {
    return Flexible(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
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

  Widget _actionButtons({
    required String docId,
    required Map<String, dynamic> data,
    required String currentStatus,
  }) {
    return Row(
      children: [
        Expanded(
          child: _actionButton(
            label: "PENDING",
            color: Colors.orange,
            icon: Icons.hourglass_top_rounded,
            disabled: isUpdating ||
                currentStatus.toLowerCase() == "pending",
            onTap: () {
              konfirmasiStatus(
                docId: docId,
                data: data,
                statusBaru: "Pending",
              );
            },
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _actionButton(
            label: "TOLAK",
            color: Colors.red,
            icon: Icons.close_rounded,
            disabled: isUpdating ||
                currentStatus.toLowerCase() == "ditolak",
            onTap: () {
              konfirmasiStatus(
                docId: docId,
                data: data,
                statusBaru: "Ditolak",
              );
            },
          ),
        ),

        const SizedBox(width: 8),

        Expanded(
          child: _actionButton(
            label: "TERIMA",
            color: Colors.green,
            icon: Icons.check_rounded,
            disabled: isUpdating ||
                currentStatus.toLowerCase() == "diterima",
            onTap: () {
              konfirmasiStatus(
                docId: docId,
                data: data,
                statusBaru: "Diterima",
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required IconData icon,
    required bool disabled,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: disabled ? null : onTap,
      icon: Icon(
        icon,
        size: 16,
        color: Colors.white,
      ),
      label: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        disabledBackgroundColor: color.withOpacity(0.35),
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
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
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.assignment_late_outlined,
              color: Colors.grey,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Tidak Ada Pendaftaran",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            "Belum ada pasien yang mendaftar pada tanggal ${formatTanggal(selectedDate)}.",
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