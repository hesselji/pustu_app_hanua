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

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus(); // 🔥 tutup keyboard

    setState(() => isLoading = true);

    try {
      final query = await FirebaseFirestore.instance
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

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passwordController.text.trim(),
      );

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

  Future<void> resetPassword() async {
    FocusScope.of(context).unfocus(); // 🔥 tutup keyboard

    final username = usernameController.text.trim();

    if (username.isEmpty) {
      _showErrorDialog("Masukkan username dulu");
      return;
    }

    try {
      final query = await FirebaseFirestore.instance
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
        builder: (_) => AlertDialog(
          title: const Text("Berhasil"),
          content: Text("Link reset password dikirim ke $email"),
        ),
      );
    } catch (e) {
      _showErrorDialog("Gagal reset password");
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
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
    return WillPopScope(
      onWillPop: () async {
        if (FocusScope.of(context).hasFocus) {
          FocusScope.of(context).unfocus(); // 🔥 tutup keyboard dulu
          return false; // ❗ jangan langsung back (hindari glitch)
        }
        return true;
      },
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(), // 🔥 tap kosong
        child: Scaffold(
          resizeToAvoidBottomInset: false, // 🔥 penting biar stabil
          body: SafeArea(
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back),
                        onPressed: () async {
                          if (FocusScope.of(context).hasFocus) {
                            FocusScope.of(context).unfocus();
                            await Future.delayed(
                                const Duration(milliseconds: 100));
                          }
                          Navigator.pop(context);
                        },
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
                        style: TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold),
                      ),

                      const SizedBox(height: 30),

                      Form(
                        key: _formKey,
                        child: Column(
                          children: [
                            TextFormField(
                              controller: usernameController,
                              decoration: InputDecoration(
                                labelText: "Username",
                                prefixIcon: const Icon(Icons.person),
                                border: OutlineInputBorder(
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => v!.isEmpty
                                  ? "Username tidak boleh kosong"
                                  : null,
                            ),

                            const SizedBox(height: 20),

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
                                  borderRadius:
                                      BorderRadius.circular(12),
                                ),
                              ),
                              validator: (v) => v!.isEmpty
                                  ? "Password tidak boleh kosong"
                                  : null,
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: resetPassword,
                                child: const Text("Lupa Password?"),
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                    isLoading ? null : login,
                                child: isLoading
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

                /// 🔥 FOOTER (TIDAK DIUBAH POSISINYA)
                const Positioned(
                  bottom: 10,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Text(
                      "© Pustu Hanua 2026",
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}