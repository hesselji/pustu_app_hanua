import 'package:flutter/material.dart';
import 'patient_register_screen.dart';
import 'patient_cekberobat_screen.dart';
import 'about_us.dart';

class PatientHomeScreen extends StatelessWidget {
  const PatientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  const Spacer(),

                  _logo("Kemenkes"),
                  const SizedBox(width: 10),
                  _logo("Pustu"),

                  const Spacer(),

                  const Text(
                    "Pustu Hanua",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const Divider(),

            const SizedBox(height: 10),

            /// 🔹 TITLE
            const Text(
              "BERANDA PASIEN",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            /// 🔹 MENU LIST
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: ListView(
                  children: [
                    _menuCard(
                      title: "Daftar Berobat",
                      icon: Icons.medical_services,
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

                    const SizedBox(height: 20),

                    _menuCard(
                      title: "Lihat Daftar Berobat",
                      icon: Icons.list_alt,
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

                    const SizedBox(height: 20),

                    _menuCard(
                      title: "About Us",
                      icon: Icons.info,
                      color: Colors.orange,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const AboutUsPage(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            /// 🔹 FOOTER
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "Copyright © 2026",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔸 COMPONENT LOGO
  Widget _logo(String text) {
    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image, size: 18, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(text, style: const TextStyle(fontSize: 8)),
      ],
    );
  }

  /// 🔸 COMPONENT MENU CARD
  Widget _menuCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            /// ICON
            Container(
              width: 80,
              height: double.infinity,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
              ),
              child: Icon(icon, color: color, size: 30),
            ),

            const SizedBox(width: 15),

            /// TEXT
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            const Padding(
              padding: EdgeInsets.only(right: 15),
              child: Icon(Icons.arrow_forward_ios, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}
