import 'package:flutter/material.dart';
import '../../services/patient_auth_helper.dart';
import '../../services/fcm_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_screen.dart';
import 'patient_register_screen.dart';
import 'patient_cekberobat_screen.dart';
import 'about_us.dart';

class PatientHomeScreen extends StatefulWidget {
  const PatientHomeScreen({super.key});

  @override
  State<PatientHomeScreen> createState() => _PatientHomeScreenState();
}

class _PatientHomeScreenState extends State<PatientHomeScreen> {
  final Color primaryGreen = const Color(0xFF1B7F3A);
  final Color darkGreen = const Color(0xFF0E4D2C);
  final Color softGreen = const Color(0xFFE8F5E9);
  final Color background = const Color(0xFFF5F7FA);

  bool isPhoneVisible = false;

  late Future<DocumentSnapshot<Map<String, dynamic>>?> _patientFuture;

  @override
void initState() {
  super.initState();
  _patientFuture = _getPatientData();
  _setupPatientNotification();
}

Future<void> _setupPatientNotification() async {
  final patientUid = await PatientAuthHelper.getCurrentPatientUid();

  if (patientUid == null) return;

  await FcmService.subscribePatientTopicAndSaveToken(
    patientUid: patientUid,
  );
}

Future<DocumentSnapshot<Map<String, dynamic>>?> _getPatientData() async {
  final patientUid = await PatientAuthHelper.getCurrentPatientUid();

  if (patientUid == null) return null;

  return FirebaseFirestore.instance
      .collection('patient_users')
      .doc(patientUid)
      .get();
}

Future<void> _logout() async {
  FocusManager.instance.primaryFocus?.unfocus();

  await FcmService.unsubscribePatientTopic();
  await PatientAuthHelper.clearPatientSession();

  if (!mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(builder: (_) => const HomeScreen()),
    (route) => false,
  );
}

  Future<void> _confirmLogout() async {
  FocusManager.instance.primaryFocus?.unfocus();

  final bool? confirm = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
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
                'Keluar Akun?',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: const Text(
          'Apakah Anda yakin ingin keluar dari akun pasien?',
          style: TextStyle(
            height: 1.4,
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text('Batal'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(vertical: 13),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: const Text(
                    'Keluar',
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

  String _maskPhone(String phone) {
    if (phone.isEmpty) return '-';

    if (phone.length <= 4) return phone;

    final visibleEnd = phone.substring(phone.length - 4);
    return '•••• $visibleEnd';
  }

  String _displayPhone(String phone) {
    if (phone.isEmpty) return '-';

    if (!isPhoneVisible) {
      return _maskPhone(phone);
    }

    // Biar lebih mudah dibaca: 0812 3456 7890
    final clean = phone.replaceAll(' ', '');

    if (clean.length <= 4) return clean;

    final buffer = StringBuffer();

    for (int i = 0; i < clean.length; i++) {
      buffer.write(clean[i]);

      if ((i + 1) % 4 == 0 && i != clean.length - 1) {
        buffer.write(' ');
      }
    }

    return buffer.toString();
  }

  void _showGuideDialog({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> points,
  }) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
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
                  child: Icon(icon, color: color),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  points
                      .map(
                        (point) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(Icons.check_circle, size: 18, color: color),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  point,
                                  style: const TextStyle(height: 1.35),
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                      .toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  void _showServiceStatusDialog() {
    showDialog(
      context: context,
      builder:
          (_) => StreamBuilder<DocumentSnapshot>(
            stream:
                FirebaseFirestore.instance
                    .collection('service_status')
                    .doc('status')
                    .snapshots(),
            builder: (context, snapshot) {
              bool isAvailable = true;

              if (snapshot.hasData && snapshot.data!.data() != null) {
                final data = snapshot.data!.data() as Map<String, dynamic>;
                isAvailable = data['isAvailable'] ?? true;
              }

              return AlertDialog(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(22),
                ),
                title: Row(
                  children: [
                    Icon(
                      isAvailable
                          ? Icons.health_and_safety_rounded
                          : Icons.warning_amber_rounded,
                      color: isAvailable ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Status Pelayanan',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                content: Text(
                  isAvailable
                      ? 'Petugas sedang tersedia. Pasien dapat melakukan pendaftaran berobat melalui aplikasi.'
                      : 'Petugas sedang tidak tersedia. Pendaftaran berobat tetap dapat dilakukan, hanya saja waktu tunggu konfirmasi oleh perawat akan lebih lama. Jika anda membutuhkan bantuan medis segera, hubungi perawat.',
                  style: const TextStyle(height: 1.45),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Tutup'),
                  ),
                ],
              );
            },
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: FutureBuilder<DocumentSnapshot<Map<String, dynamic>>?>(
          future: _patientFuture,
          builder: (context, snapshot) {
            final data = snapshot.data?.data();

            final nama = data?['nama'] ?? 'Pasien';
            final nik = data?['nik'] ?? '-';
            final phone = data?['phone'] ?? '';

            return RefreshIndicator(
              onRefresh: () async {
                setState(() {
                  _patientFuture = _getPatientData();
                });
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _headerSection(nama: nama, nik: nik, phone: phone),

                    const SizedBox(height: 18),

                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionTitle(
                            title: 'Menu Layanan',
                            subtitle: 'Pilih layanan kesehatan yang tersedia',
                          ),

                          const SizedBox(height: 14),

                          _mainMenuGrid(),

                          const SizedBox(height: 22),

                          _sectionTitle(
                            title: 'Panduan Pasien',
                            subtitle:
                                'Informasi singkat yang membantu penggunaan aplikasi',
                          ),

                          const SizedBox(height: 14),

                          _patientGuideCards(),

                          const SizedBox(height: 22),

                          _aboutPreview(),

                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _headerSection({
    required String nama,
    required String nik,
    required String phone,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkGreen, primaryGreen, const Color(0xFF43A047)],
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
              _logoBox('assets/logo_pustu.png'),

              const SizedBox(width: 12),

              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pustu Hanua',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Layanan Kesehatan Masyarakat',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
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
                    border: Border.all(color: Colors.white.withOpacity(0.18)),
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
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.25)),
                ),
                child: const Icon(
                  Icons.person_rounded,
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
                      'Selamat datang 👋',
                      style: TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      nama,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'NIK $nik',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
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
                flex: 3,
                child: _miniHeaderInfo(
                  icon: Icons.phone_android_rounded,
                  title: 'No. Telepon',
                  value: _displayPhone(phone),
                  isPhoneValue: true,
                  trailing: InkWell(
                    onTap: () {
                      setState(() {
                        isPhoneVisible = !isPhoneVisible;
                      });
                    },
                    borderRadius: BorderRadius.circular(20),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        isPhoneVisible
                            ? Icons.visibility_off_rounded
                            : Icons.visibility_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: _miniHeaderInfo(
                  icon: Icons.verified_user_rounded,
                  title: 'Akun Pasien',
                  value: 'Aktif',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _serviceStatusCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream:
          FirebaseFirestore.instance
              .collection('service_status')
              .doc('status')
              .snapshots(),
      builder: (context, snapshot) {
        bool isAvailable = true;

        if (snapshot.hasData && snapshot.data!.data() != null) {
          final data = snapshot.data!.data() as Map<String, dynamic>;
          isAvailable = data['isAvailable'] ?? true;
        }

        return InkWell(
          onTap: _showServiceStatusDialog,
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
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color:
                        isAvailable
                            ? const Color(0xFFE8F5E9)
                            : const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isAvailable
                        ? Icons.health_and_safety_rounded
                        : Icons.warning_amber_rounded,
                    color: isAvailable ? Colors.green : Colors.red,
                    size: 28,
                  ),
                ),

                const SizedBox(width: 14),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Status Pelayanan',
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isAvailable
                            ? 'Petugas Tersedia'
                            : 'Petugas Tidak Tersedia',
                        style: TextStyle(
                          color: isAvailable ? Colors.green : Colors.red,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        isAvailable
                            ? 'Pasien dapat melakukan pendaftaran'
                            : 'Pendaftaran berobat tetap dapat dilakukan, hanya saja waktu tunggu konfirmasi akan lebih lama',
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 11,
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
                    color:
                        isAvailable
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
                        'Detail',
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
    bool isPhoneValue = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.14),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withOpacity(0.18)),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.white, size: 22),
          const SizedBox(width: 9),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.white70, fontSize: 10),
                ),
                const SizedBox(height: 2),

                // Khusus nomor telepon: jangan pakai ellipsis
                if (isPhoneValue)
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

          if (trailing != null) ...[const SizedBox(width: 4), trailing],
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

        // 🔥 SEBELUMNYA 1.25, INI PENYEBAB CARD TERLALU PENDEK
        childAspectRatio: 1.05,

        children: [
          _menuItem(
            title: 'Daftar\nBerobat',
            subtitle: 'Isi pendaftaran',
            icon: Icons.medical_services_rounded,
            color: Colors.green,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const PatientRegisterScreen(),
                ),
              );
            },
          ),
          _menuItem(
            title: 'Cek Status\nBerobat',
            subtitle: 'Lihat pendaftaran',
            icon: Icons.assignment_turned_in_rounded,
            color: Colors.blue,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PatientCheckScreen()),
              );
            },
          ),
          _menuItem(
            title: 'Info\nAplikasi',
            subtitle: 'Tentang sistem',
            icon: Icons.info_rounded,
            color: Colors.orange,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutUsPage()),
              );
            },
          ),
          _menuItem(
            title: 'Keluar\nAkun',
            subtitle: 'Logout pasien',
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
          border: Border.all(color: color.withOpacity(0.12)),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -8,
              bottom: -8,
              child: Icon(icon, size: 58, color: color.withOpacity(0.10)),
            ),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
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
                  child: Icon(icon, color: Colors.white, size: 22),
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
                  style: TextStyle(fontSize: 10.5, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _patientGuideCards() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _guideCard(
                icon: Icons.route_rounded,
                title: 'Alur Pendaftaran',
                desc: 'Lihat langkah daftar berobat',
                color: Colors.green,
                onTap: () {
                  _showGuideDialog(
                    title: 'Alur Pendaftaran',
                    icon: Icons.route_rounded,
                    color: Colors.green,
                    points: [
                      'Pilih menu Daftar Berobat.',
                      'Isi data pendaftaran dan keluhan.',
                      'Pilih tanggal, jam, dan jenis layanan.',
                      'Kirim pendaftaran dan tunggu konfirmasi petugas.',
                    ],
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _guideCard(
                icon: Icons.search_rounded,
                title: 'Cek Status',
                desc: 'Pantau pendaftaran pasien',
                color: Colors.blue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientCheckScreen(),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _guideCard(
                icon: Icons.health_and_safety_rounded,
                title: 'Status Petugas',
                desc: 'Lihat ketersediaan layanan',
                color: Colors.orange,
                onTap: _showServiceStatusDialog,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _guideCard(
                icon: Icons.home_work_rounded,
                title: 'Jenis Layanan',
                desc: 'Home Care / Pustu Visit',
                color: Colors.teal,
                onTap: () {
                  _showGuideDialog(
                    title: 'Jenis Layanan',
                    icon: Icons.home_work_rounded,
                    color: Colors.teal,
                    points: [
                      'Pustu Visit digunakan apabila pasien datang langsung ke Pustu.',
                      'Home Care digunakan apabila pasien membutuhkan kunjungan petugas.',
                      'Petugas akan menyesuaikan layanan berdasarkan kondisi dan konfirmasi pendaftaran.',
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _guideCard({
    required IconData icon,
    required String title,
    required String desc,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: Colors.grey.shade100),
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
              child: Icon(icon, color: color.withOpacity(0.08), size: 58),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(height: 14),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: Colors.grey.shade600,
                    height: 1.25,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _aboutPreview() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AboutUsPage()),
        );
      },
      borderRadius: BorderRadius.circular(26),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [softGreen, Colors.white],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(26),
          border: Border.all(color: Colors.green.withOpacity(0.12)),
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
                    'Tentang Pustu Hanua',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'Lihat informasi aplikasi, tujuan sistem, dan pengembang.',
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 12,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),

            const Icon(
              Icons.arrow_forward_ios_rounded,
              size: 16,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle({required String title, required String subtitle}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 3),
        Text(
          subtitle,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
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
          BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8),
        ],
      ),
      child: Image.asset(assetPath, fit: BoxFit.contain),
    );
  }
}
