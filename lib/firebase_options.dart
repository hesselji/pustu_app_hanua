import 'package:firebase_core/firebase_core.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform => web;

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyASGYRWDE5ta2ioVvQ7BmeSWKp_wVWI3lU",
    authDomain: "pustu-hanua-app.firebaseapp.com",
    projectId: "pustu-hanua-app",
    storageBucket: "pustu-hanua-app.firebasestorage.app",
    messagingSenderId: "846267024541",
    appId: "1:846267024541:web:73188ee93082c41d184074",
    measurementId: "G-HV8RCPVE8N",
  );
}