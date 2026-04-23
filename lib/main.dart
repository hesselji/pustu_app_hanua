import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'screens/mobile/home_screen.dart';
import 'provider/service_status.dart';
import 'firebase_options.dart';

import 'screens/mobile/splash_screen.dart';
import 'provider/service_status.dart';
import 'firebase_options.dart';
import 'screens/desktop/web_home_screen.dart';

/// 🔥 CUSTOM SCROLL (BIAR WEB BISA DRAG)
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 INIT FIREBASE
  if (kIsWeb) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ServiceStatus(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// 🔥 INI YANG PENTING
      home:
          kIsWeb
              ? const WebHomeScreen() // 💻 WEB
              : const HomeScreen(), // 📱 MOBILE
      /// 🔥 INI KUNCI BIAR SCROLL WEB NORMAL
      scrollBehavior: MyCustomScrollBehavior(),

      /// 🎨 OPTIONAL (BIAR LEBIH ESTETIK GLOBAL)
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: 'Roboto',
      ),
    );
  }
}
