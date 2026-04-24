import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/rendering.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'dart:ui';

import 'provider/service_status.dart';
import 'firebase_options.dart';
import 'screens/desktop/web_home_screen.dart';
import 'widgets/network_overlay.dart';
import '../screens/wrapper/auth_wrapper.dart'; // 🔥 TAMBAH INI

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

      /// 🔥 ROOT SCREEN (INI YANG DIGANTI)
      home: kIsWeb
          ? const WebHomeScreen()
          : const AuthWrapper(), // 🔥 AUTO LOGIN DI SINI

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