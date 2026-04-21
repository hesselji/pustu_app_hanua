import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../wrapper/perawat_wrapper.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  bool isObscure = true;
  bool isLoading = false;

  /// 🔐 LOGIN DENGAN USERNAME
  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => isLoading = true);

    try {
      /// 🔍 CARI EMAIL DARI USERNAME
      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: usernameController.text.trim())
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'Username tidak ditemukan',
        );
      }

      final email = query.docs.first['email'];

      /// 🔑 LOGIN KE FIREBASE AUTH
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passwordController.text.trim(),
      );

      /// 🚀 MASUK KE BERANDA PERAWAT
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PerawatWrapper()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = "Login gagal";

      if (e.code == 'user-not-found') {
        message = "Username tidak ditemukan";
      } else if (e.code == 'wrong-password') {
        message = "Password salah";
      }

      _showErrorDialog(message);
    } finally {
      setState(() => isLoading = false);
    }
  }

  /// 🔁 RESET PASSWORD
  Future<void> resetPassword() async {
    final username = usernameController.text.trim();

    if (username.isEmpty) {
      _showErrorDialog("Masukkan username dulu");
      return;
    }

    try {
      final query =
          await FirebaseFirestore.instance
              .collection('users')
              .where('username', isEqualTo: username)
              .limit(1)
              .get();

      if (query.docs.isEmpty) {
        throw Exception("Username tidak ditemukan");
      }

      final email = query.docs.first['email'];

      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      showDialog(
        context: context,
        builder:
            (_) => AlertDialog(
              title: const Text("Berhasil"),
              content: Text("Link reset password dikirim ke $email"),
            ),
      );
    } catch (e) {
      _showErrorDialog("Gagal reset password");
    }
  }

  /// ❌ POPUP ERROR ESTETIK
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder:
          (_) => Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 15),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("OK"),
                  ),
                ],
              ),
            ),
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),

                  const SizedBox(height: 20),

                  const Icon(
                    Icons.local_hospital,
                    size: 80,
                    color: Colors.green,
                  ),

                  const SizedBox(height: 10),

                  const Text(
                    "Login Perawat",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),

                  const SizedBox(height: 30),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        /// USERNAME
                        TextFormField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: "Username",
                            prefixIcon: const Icon(Icons.person),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (v) =>
                                  v!.isEmpty
                                      ? "Username tidak boleh kosong"
                                      : null,
                        ),

                        const SizedBox(height: 20),

                        /// PASSWORD
                        TextFormField(
                          controller: passwordController,
                          obscureText: isObscure,
                          decoration: InputDecoration(
                            labelText: "Password",
                            prefixIcon: const Icon(Icons.lock),
                            suffixIcon: IconButton(
                              icon: Icon(
                                isObscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ),
                              onPressed: () {
                                setState(() {
                                  isObscure = !isObscure;
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator:
                              (v) =>
                                  v!.isEmpty
                                      ? "Password tidak boleh kosong"
                                      : null,
                        ),

                        /// 🔁 LUPA PASSWORD
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: resetPassword,
                            child: const Text("Lupa Password?"),
                          ),
                        ),

                        const SizedBox(height: 20),

                        /// LOGIN BUTTON
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            child:
                                isLoading
                                    ? const CircularProgressIndicator(
                                      color: Colors.white,
                                    )
                                    : const Text("LOGIN"),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const Positioned(
              bottom: 10,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "© Pustu Hanua 2026",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
