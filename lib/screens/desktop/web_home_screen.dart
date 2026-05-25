import 'package:flutter/material.dart';
import 'web_login_screen.dart';

class WebHomeScreen extends StatelessWidget {
  const WebHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAF9),

      body: SingleChildScrollView(
        child: Column(
          children: [

            /// 🔥 NAVBAR
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
              color: Colors.white,
              child: Row(
                children: [
                  Row(
                    children: [
                      Image.asset("assets/logo_pustu.png", height: 35),
                      const SizedBox(width: 10),
                      const Text(
                        "Pustu Hanua",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const Spacer(),

                  TextButton(onPressed: () {}, child: const Text("Beranda")),
                  TextButton(onPressed: () {}, child: const Text("Fitur")),
                  TextButton(onPressed: () {}, child: const Text("Tentang")),

                  const SizedBox(width: 20),

                  /// 🔥 BUTTON LOGIN (FIXED)
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const WebLoginScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 25, vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text("Login"),
                  ),
                ],
              ),
            ),

            /// 🔥 HERO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 80),
              child: SizedBox(
                height: 600,
                child: Row(
                  children: [

                    /// LEFT
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          const Text(
                            "Sistem Informasi\nPelayanan Kesehatan",
                            style: TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 20),

                          const Text(
                            "Platform digital untuk membantu tenaga kesehatan\n"
                            "mengelola data pasien, rekam medis, dan layanan\n"
                            "secara efisien dan modern.",
                            style: TextStyle(color: Colors.grey),
                          ),

                          const SizedBox(height: 40),

                          Row(
                            children: [

                              /// 🔥 BUTTON UTAMA (FIXED)
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => const WebLoginScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 30, vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: const Text("Mulai Sekarang"),
                              ),

                              const SizedBox(width: 20),

                              OutlinedButton(
                                onPressed: () {},
                                child: const Text("Pelajari"),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),

                    /// RIGHT
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.all(40),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color: Colors.green.shade50,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset("assets/logo_pustu.png", height: 120),
                            const SizedBox(height: 20),
                            const Text(
                              "Smart Health System",
                              style: TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            /// 🔥 FEATURES
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: 80, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  FeatureCard(
                    icon: Icons.people,
                    title: "Manajemen Pasien",
                    desc: "Kelola data pasien dengan mudah",
                  ),
                  FeatureCard(
                    icon: Icons.medical_services,
                    title: "Rekam Medis",
                    desc: "Riwayat kesehatan digital",
                  ),
                  FeatureCard(
                    icon: Icons.bar_chart,
                    title: "Laporan",
                    desc: "Analisis data kesehatan",
                  ),
                ],
              ),
            ),

            /// FOOTER
            const Padding(
              padding: EdgeInsets.only(bottom: 20),
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
}

////////////////////////////////////////////////////////////
/// 🔥 FEATURE CARD
class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 10),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: Colors.green),
          const SizedBox(height: 15),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          Text(desc,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey)),
        ],
      ),
    );
  }
}