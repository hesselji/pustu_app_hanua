import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'patient_home_screen.dart';
import 'login_screen.dart';
import 'perawat_home_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
 State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  @override
  void initState() {
    super.initState();

    /// 🔥 AUTO LOGIN CHECK
    Future.microtask(() {
      final user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const PerawatHomeScreen(),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E9), Color(0xFFFFFFFF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              /// 🔹 LOGO ATAS
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _logoPlaceholder("Bakti Husada"),
                    _logoPlaceholder("Kemenkes"),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              /// 🔹 GAMBAR PUSTU
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  height: 180,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    color: Colors.grey[300],
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      "GAMBAR PUSTU",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              /// 🔹 TEXT SELAMAT DATANG
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: const [
                    Text(
                      "SELAMAT DATANG",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 10),
                    Text(
                      "DI APLIKASI LAYANAN KESEHATAN\nPUSKESMAS PEMBANTU HANUA",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 40),

              /// 🔹 BUTTON PERAWAT
              _customButton(
                text: "Masuk sebagai Perawat",
                icon: Icons.medical_services,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                  );
                },
              ),

              const SizedBox(height: 20),

              /// 🔹 BUTTON PASIEN
              _customButton(
                text: "Masuk sebagai Pasien",
                icon: Icons.person,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PatientHomeScreen(),
                    ),
                  );
                },
              ),

              const Spacer(),

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
      ),
    );
  }

  /// 🔸 COMPONENT LOGO
  Widget _logoPlaceholder(String text) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          color: Colors.grey[300],
          child: const Icon(Icons.image, color: Colors.grey),
        ),
        const SizedBox(height: 5),
        Text(text, style: const TextStyle(fontSize: 10)),
      ],
    );
  }

  /// 🔸 COMPONENT BUTTON
  Widget _customButton({
    required String text,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 55,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 10),
              Text(
                text,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}