import 'package:flutter/material.dart';
import '../mobile/patient_list_screen.dart';
import '../desktop/perawat_dashboard_desktop.dart';

class PerawatWrapper extends StatelessWidget {
  const PerawatWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width > 800) {
      return const PerawatDashboardDesktop(); // 💻 WEB
    } else {
      return const PatientListScreen(); // 📱 MOBILE
    }
  }
}