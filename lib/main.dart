import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'provider/service_status.dart';
import 'firebase_options.dart';
import 'screens/desktop/web_home_screen.dart';
import 'screens/desktop/web_perawat_dashboard.dart'; // 🔥 TAMBAH
import 'widgets/network_overlay.dart';
import '../screens/wrapper/auth_wrapper.dart';

/// 🔥 CUSTOM SCROLL (WEB DRAG)
class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 MATIKAN DEBUG PAINT
  debugPaintSizeEnabled = false;
  debugPaintBaselinesEnabled = false;
  debugPaintLayerBordersEnabled = false;
  debugPaintPointersEnabled = false;
  debugRepaintRainbowEnabled = false;

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

      /// 🔥 GLOBAL OVERLAY
      builder: (context, child) {
        return NetworkOverlay(child: child!);
      },

      /// 🔥 ROOT SCREEN (FIX DI SINI)
      home:
          kIsWeb
              ? const WebAuthWrapper() // 🔥 GANTI INI
              : const AuthWrapper(),

      /// 🔥 SCROLL WEB
      scrollBehavior: MyCustomScrollBehavior(),

      /// 🎨 THEME
      theme: ThemeData(
        primarySwatch: Colors.green,
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
        fontFamily: null,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(decoration: TextDecoration.none),
          bodyLarge: TextStyle(decoration: TextDecoration.none),
        ),
      ),
    );
  }
}

/// 🔥 WRAPPER KHUSUS WEB (INI KUNCI SOLUSI)
class WebAuthWrapper extends StatelessWidget {
  const WebAuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        /// LOADING
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        /// 🔥 SELALU LEWAT SPLASH
        return WebSplashRouter(isLoggedIn: snapshot.hasData);
      },
    );
  }
}

class WebSplashRouter extends StatefulWidget {
  final bool isLoggedIn;

  const WebSplashRouter({super.key, required this.isLoggedIn});

  @override
  State<WebSplashRouter> createState() => _WebSplashRouterState();
}

class _WebSplashRouterState extends State<WebSplashRouter> {
  @override
  void initState() {
    super.initState();

    /// DELAY SPLASH (2 detik)
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder:
              (_) =>
                  widget.isLoggedIn
                      ? const WebPerawatDashboard()
                      : const WebHomeScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    /// 🔥 SPLASH UI (BISA KAMU CUSTOM)
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("assets/logo_pustu.png", height: 80),
            const SizedBox(height: 20),
            const CircularProgressIndicator(),
            const SizedBox(height: 20),
            const Text(
              "Memuat sistem...",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
