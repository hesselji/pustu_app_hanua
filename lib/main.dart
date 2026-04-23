import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'screens/mobile/splash_screen.dart'; // 🔥 TAMBAHAN
import 'provider/service_status.dart';
import 'firebase_options.dart';
import 'screens/desktop/web_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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

      /// 🔥 FIX FINAL
      home: kIsWeb
          ? const WebHomeScreen()   // 💻 WEB tetap
          : const SplashScreen(),  // 📱 MOBILE pakai splash
    );
  }
}