import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:pustu_app_hanua/screens/mobile/home_screen.dart';
import '../wrapper/perawat_wrapper.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        /// 🔥 LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// 🔥 SUDAH LOGIN
        if (snapshot.hasData) {
          return const PerawatWrapper();
        }

        /// 🔥 BELUM LOGIN
        return const HomeScreen();
      },
    );
  }
}