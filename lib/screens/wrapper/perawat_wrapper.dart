import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

import '../desktop/web_home_screen.dart';
import '../mobile/perawat_home_screen.dart';

class PerawatWrapper extends StatelessWidget {
  const PerawatWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    /// 💻 WEB (PASTI KE DESKTOP)
    if (kIsWeb) {
      return const WebHomeScreen();
    }

    /// 📱 MOBILE / TABLET
    if (width > 800) {
      return const WebHomeScreen(); // tablet
    } else {
      return const PerawatHomeScreen(); // hp
    }
  }
}