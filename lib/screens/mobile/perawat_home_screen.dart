import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'patient_list_screen.dart';
import 'perawat_manageinfo_pelayanan.dart';
import 'perawat_laporanBulanan.dart'; // ✅ TAMBAHAN
import 'perawat_manageinfo_pelayanan.dart'; // 🔥 TAMBAHAN
import 'medical_patient_list_screen.dart';

class PerawatHomeScreen extends StatelessWidget {
  const PerawatHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      /// 🔝 APP BAR
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        automaticallyImplyLeading: false,
        title: const Row(
          children: [
            Icon(Icons.local_hospital, color: Colors.green),
            SizedBox(width: 8),
            Text("Pustu Hanua", style: TextStyle(color: Colors.black)),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.red),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();

              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
                (route) => false,
              );
            },
          ),
        ],
      ),

      /// 📱 BODY
      body: SafeArea(
        child: Column(
          children: [
            /// 🧑 HEADER USER
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  const Text(
                    "BERANDA PERAWAT",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    user?.email ?? "",
                    style: const TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),

            const Divider(),

            /// 🔹 LABEL MENU
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "All Menu",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            /// 📋 LIST MENU
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  /// 🔹 Kelola Pendaftaran
                  _menuCard(
                    icon: Icons.assignment,
                    title: "Kelola Pendaftaran",
                    onTap: () {
                      // TODO
                    },
                  ),

                  /// 🔹 Data Pasien
                  _menuCard(
                    icon: Icons.people,
                    title: "Kelola Data Pasien",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const PatientListScreen(),
                        ),
                      );
                    },
                  ),

                  /// 🔹 Rekam Medis
                  _menuCard(
                    icon: Icons.medical_services,
                    title: "Kelola Rekam Medis",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const MedicalPatientListScreen(),
                        ),
                      );
                    },
                  ),

                  /// 🔹 Informasi Pelayanan
                  _menuCard(
                    icon: Icons.info,
                    title: "Informasi Pelayanan",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const InformasiPelayananScreen(),
                        ),
                      );
                    },
                  ),

                  /// 🔥 Laporan Bulanan (SUDAH TERHUBUNG)
                  _menuCard(
                    icon: Icons.bar_chart,
                    title: "Laporan Bulanan",
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RekapanBulananPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            /// 🔻 FOOTER
            const Padding(
              padding: EdgeInsets.all(12),
              child: Text(
                "© Pustu Hanua 2026",
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔥 WIDGET CARD MENU
  Widget _menuCard({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.green),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }
}
