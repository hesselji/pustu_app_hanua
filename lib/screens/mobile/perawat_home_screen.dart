import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'patient_list_screen.dart';
import 'perawat_manageinfo_pelayanan.dart';
import 'perawat_laporanBulanan.dart';
import 'medical_patient_list_screen.dart';
import 'perawat_kelolaPendaftaran.dart';

class PerawatHomeScreen extends StatefulWidget {
  const PerawatHomeScreen({super.key});

  @override
  State<PerawatHomeScreen> createState() => _PerawatHomeScreenState();
}

class _PerawatHomeScreenState extends State<PerawatHomeScreen> {
  final Color primaryGreen = const Color(0xFF1B7F3A);
  final Color darkGreen = const Color(0xFF0E4D2C);
  final Color softGreen = const Color(0xFFE8F5E9);
  final Color background = const Color(0xFFF5F7FA);

  String username = "";
  String email = "";
  bool isLoading = true;
  bool isEmailVisible = false;

  late final Stream<QuerySnapshot<Map<String, dynamic>>> todayRegistrationStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> pendingRegistrationStream;
  late final Stream<QuerySnapshot<Map<String, dynamic>>> patientStream;
  late final Stream<DocumentSnapshot<Map<String, dynamic>>> serviceStatusStream;

  @override
  void initState() {
    super.initState();

    todayRegistrationStream = _buildTodayRegistrationStream();
    pendingRegistrationStream = _buildPendingRegistrationStream();
    patientStream = FirebaseFirestore.instance.collection('patients').snapshots();

    serviceStatusStream = FirebaseFirestore.instance
        .collection('service_status')
        .doc('status')
        .snapshots();

    fetchUser();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _buildTodayRegistrationStream() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('registrations')
        .where('tanggal', isGreaterThanOrEqualTo: Timestamp.fromDate(start))
        .where('tanggal', isLessThan: Timestamp.fromDate(end))
        .snapshots();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> _buildPendingRegistrationStream() {
    return FirebaseFirestore.instance
        .collection('registrations')
        .where('status', whereIn: ['Pending', 'pending', 'PENDING'])
        .snapshots();
  }

  Future<void> fetchUser() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      if (!mounted) return;

      setState(() {
        username = "-";
        email = "-";
        isLoading = false;
      });

      return;
    }

    try {
      final query = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: user.email)
          .limit(1)
          .get();

      if (!mounted) return;

      if (query.docs.isNotEmpty) {
        setState(() {
          username = query.docs.first['username'] ?? "Perawat";
          email = user.email ?? "-";
          isLoading = false;
        });
      } else {
        setState(() {
          username = "Perawat";
          email = user.email ?? "-";
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        username = "Perawat";
        email = user.email ?? "-";
        isLoading = false;
      });
    }
  }

  Future<void> _refreshData() async {
    await fetchUser();
  }

  String _maskEmail(String value) {
    if (value.isEmpty || value == "-") return "-";

    final parts = value.split('@');
    if (parts.length != 2) return "••••••";

    final name = parts[0];
    final domain = parts[1];

    if (name.length <= 2) {
      return "•••@$domain";
    }

    final first = name.substring(0, 2);
    return "$first••••@$domain";
  }

  String _displayEmail(String value) {
    if (value.isEmpty) return "-";
    return isEmailVisible ? value : _maskEmail(value);
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  Future<void> _confirmLogout() async {
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
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.logout_rounded,
                  color: Colors.red,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Keluar Akun?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: const Text(
            "Apakah Anda yakin ingin keluar dari akun perawat?",
            style: TextStyle(height: 1.4),
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
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Keluar",
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
      await _logout();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _headerSection(),
                const SizedBox(height: 18),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle(
                        title: "Dashboard Statistik",
                        subtitle:
                            "Ringkasan data pelayanan yang diperbarui secara real-time",
                      ),
                      const SizedBox(height: 14),
                      _dashboardStatisticSection(),

                      const SizedBox(height: 22),

                      _sectionTitle(
                        title: "Menu Utama",
                        subtitle: "Kelola layanan dan data kesehatan",
                      ),
                      const SizedBox(height: 14),
                      _mainMenuGrid(),

                      const SizedBox(height: 22),
                      _footerInfo(),
                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerSection() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
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
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.28),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              _logoBox("assets/logo_pustu.png"),
              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Pustu Hanua",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      "Dashboard Perawat",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              InkWell(
                onTap: _confirmLogout,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.16),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                    ),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 62,
                height: 62,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withOpacity(0.25),
                  ),
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  color: Colors.white,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Selamat bertugas 👋",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 3),

                    isLoading
                        ? const SizedBox(
                            height: 22,
                            width: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            username.isEmpty ? "Perawat" : username,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                    const SizedBox(height: 4),

                    const Text(
                      "Pengelolaan layanan kesehatan digital",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          _serviceStatusCard(),

          const SizedBox(height: 14),

          Row(
            children: [
              Expanded(
                flex: 2,
                child: _miniHeaderInfo(
                  icon: Icons.verified_user_rounded,
                  title: "Akses",
                  value: "Perawat",
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: _miniHeaderInfo(
                  icon: Icons.email_rounded,
                  title: "Email",
                  value: _displayEmail(email),
                  isEmailValue: true,
                  trailing: InkWell(
                    onTap: () {
                      setState(() {
                        isEmailVisible = !isEmailVisible;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isEmailVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceStatusCard() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: serviceStatusStream,
      builder: (context, snapshot) {
        bool isAvailable = true;

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data()!;
          isAvailable = data['isAvailable'] ?? true;
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const InformasiPelayananScreen(),
              ),
            );
          },
          borderRadius: BorderRadius.circular(24),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.96),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? const Color(0xFFE8F5E9)
                        : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isAvailable
                        ? Icons.health_and_safety_rounded
                        : Icons.warning_amber_rounded,
                    color: isAvailable ? Colors.green : Colors.red,
                    size: 29,
                  ),
                ),

                const SizedBox(width: 14),

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
                      const SizedBox(height: 4),
                      Text(
                        isAvailable
                            ? "Pelayanan Tersedia"
                            : "Pelayanan Tidak Tersedia",
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isAvailable
                            ? "Pasien dapat melakukan pendaftaran"
                            : "Status layanan sedang dinonaktifkan",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),

                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: isAvailable
                        ? Colors.green.withOpacity(0.10)
                        : Colors.red.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.circle,
                        size: 9,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        "Kelola",
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _miniHeaderInfo({
    required IconData icon,
    required String title,
    required String value,
    Widget? trailing,
    bool isEmailValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withOpacity(0.18),
        ),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 22,
          ),
          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
                const SizedBox(height: 2),

                if (isEmailValue)
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      value,
                      maxLines: 1,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  )
                else
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          if (trailing != null) ...[
            const SizedBox(width: 4),
            trailing,
          ],
        ],
      ),
    );
  }

  Widget _dashboardStatisticSection() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _queryStatisticCard(
                stream: todayRegistrationStream,
                icon: Icons.today_rounded,
                title: "Hari Ini",
                label: "Pendaftaran",
                subtitle: "Jadwal hari ini",
                color: Colors.blue,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _queryStatisticCard(
                stream: pendingRegistrationStream,
                icon: Icons.hourglass_top_rounded,
                title: "Menunggu",
                label: "Pending",
                subtitle: "Perlu konfirmasi",
                color: Colors.orange,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Row(
          children: [
            Expanded(
              child: _queryStatisticCard(
                stream: patientStream,
                icon: Icons.people_alt_rounded,
                title: "Total Pasien",
                label: "Pasien",
                subtitle: "Data tersimpan",
                color: Colors.green,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _serviceStatisticCard(),
            ),
          ],
        ),
      ],
    );
  }

  Widget _queryStatisticCard({
    required Stream<QuerySnapshot<Map<String, dynamic>>> stream,
    required IconData icon,
    required String title,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: stream,
      builder: (context, snapshot) {
        final isWaiting = snapshot.connectionState == ConnectionState.waiting;
        final count = snapshot.hasData ? snapshot.data!.docs.length : 0;

        return _baseStatisticCard(
          icon: icon,
          title: title,
          value: isWaiting ? "..." : count.toString(),
          label: label,
          subtitle: subtitle,
          color: color,
        );
      },
    );
  }

  Widget _serviceStatisticCard() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: serviceStatusStream,
      builder: (context, snapshot) {
        bool isAvailable = true;

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data()!;
          isAvailable = data['isAvailable'] ?? true;
        }

        return _baseStatisticCard(
          icon: isAvailable
              ? Icons.health_and_safety_rounded
              : Icons.warning_amber_rounded,
          title: "Status",
          value: isAvailable ? "Aktif" : "Nonaktif",
          label: "Layanan",
          subtitle: "Info pasien",
          color: isAvailable ? Colors.teal : Colors.red,
        );
      },
    );
  }

  Widget _baseStatisticCard({
    required IconData icon,
    required String title,
    required String value,
    required String label,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      height: 165,
      padding: const EdgeInsets.all(15),
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
      child: Stack(
        children: [
          Positioned(
            right: -8,
            bottom: -10,
            child: Icon(
              icon,
              color: color.withOpacity(0.08),
              size: 64,
            ),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 24,
                ),
              ),

              const SizedBox(height: 16),

              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 21,
                ),
              ),

              const SizedBox(height: 4),

              Text(
                "$label • $subtitle",
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10.5,
                  height: 1.25,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _mainMenuGrid() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 1.02,
        children: [
          _menuItem(
            title: "Kelola\nPendaftaran",
            subtitle: "Data daftar berobat",
            icon: Icons.assignment_rounded,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PerawatKelolaPendaftaranScreen(),
                ),
              );
            },
          ),
          _menuItem(
            title: "Data\nPasien",
            subtitle: "Identitas pasien",
            icon: Icons.people_alt_rounded,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientListScreen(),
                ),
              );
            },
          ),
          _menuItem(
            title: "Rekam\nMedis",
            subtitle: "Riwayat pelayanan",
            icon: Icons.medical_information_rounded,
            color: Colors.teal,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MedicalPatientListScreen(),
                ),
              );
            },
          ),
          _menuItem(
            title: "Informasi\nPelayanan",
            subtitle: "Status layanan",
            icon: Icons.campaign_rounded,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const InformasiPelayananScreen(),
                ),
              );
            },
          ),
          _menuItem(
            title: "Laporan\nBulanan",
            subtitle: "Rekap pelayanan",
            icon: Icons.bar_chart_rounded,
            color: Colors.deepPurple,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const RekapanBulananPage(),
                ),
              );
            },
          ),
          _menuItem(
            title: "Keluar\nAkun",
            subtitle: "Logout perawat",
            icon: Icons.logout_rounded,
            color: Colors.red,
            onTap: _confirmLogout,
          ),
        ],
      ),
    );
  }

  Widget _menuItem({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: color.withOpacity(0.12),
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              bottom: -8,
              child: Icon(
                icon,
                size: 58,
                color: color.withOpacity(0.10),
              ),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    icon,
                    color: Colors.white,
                    size: 23,
                  ),
                ),

                const Spacer(),

                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    height: 1.12,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _footerInfo() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            softGreen,
            Colors.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
          color: Colors.green.withOpacity(0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.local_hospital_rounded,
              color: Colors.green,
              size: 28,
            ),
          ),

          const SizedBox(width: 14),

          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pustu Hanua Digital",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  "Dashboard perawat untuk memantau pendaftaran, pasien, rekam medis, informasi pelayanan, dan laporan bulanan.",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.35,
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

  Widget _logoBox(String assetPath) {
    return Container(
      width: 48,
      height: 48,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(17),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
          ),
        ],
      ),
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
      ),
    );
  }
}