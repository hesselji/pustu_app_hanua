import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:pustu_app_hanua/screens/mobile/home_screen.dart';
import 'package:pustu_app_hanua/screens/mobile/patient_home_screen.dart';
import '../wrapper/perawat_wrapper.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<Widget> _getHomeByRole(User user) async {
    final patientDoc = await FirebaseFirestore.instance
        .collection('patient_users')
        .doc(user.uid)
        .get();

    if (patientDoc.exists) {
      return const PatientHomeScreen();
    }

    final perawatQuery = await FirebaseFirestore.instance
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1)
        .get();

    if (perawatQuery.docs.isNotEmpty) {
      return const PerawatWrapper();
    }

    await FirebaseAuth.instance.signOut();
    return const HomeScreen();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        /// LOADING AUTH
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// BELUM LOGIN
        if (!snapshot.hasData) {
          return const HomeScreen();
        }

        /// SUDAH LOGIN → CEK ROLE
        return FutureBuilder<Widget>(
          future: _getHomeByRole(snapshot.data!),
          builder: (context, roleSnapshot) {
            if (roleSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (roleSnapshot.hasData) {
              return roleSnapshot.data!;
            }

            return const HomeScreen();
          },
        );
      },
    );
  }
}