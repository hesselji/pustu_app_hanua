import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/patient_auth_helper.dart';
import 'patient_home_screen.dart';
import 'patient_signup_screen.dart';

class PatientLoginScreen extends StatefulWidget {
  const PatientLoginScreen({super.key});

  @override
  State<PatientLoginScreen> createState() => _PatientLoginScreenState();
}

class _PatientLoginScreenState extends State<PatientLoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool isObscure = true;
  bool isLoading = false;
  bool _isSubmitted = false;

  Future<void> goBackSmooth() async {
  FocusManager.instance.primaryFocus?.unfocus();

  await Future.delayed(const Duration(milliseconds: 180));

  if (!mounted) return;

  Navigator.pop(context);
}

  @override
  void initState() {
    super.initState();

    phoneController.addListener(_validateAfterSubmit);
    passwordController.addListener(_validateAfterSubmit);
  }

  void _validateAfterSubmit() {
    if (_isSubmitted) {
      _formKey.currentState?.validate();
      setState(() {});
    }
  }

  @override
  void dispose() {
    phoneController.removeListener(_validateAfterSubmit);
    passwordController.removeListener(_validateAfterSubmit);

    phoneController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  Future<void> loginPatient() async {
    setState(() {
      _isSubmitted = true;
    });

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      final phone = PatientAuthHelper.normalizePhone(phoneController.text);
      final email = PatientAuthHelper.phoneToEmail(phone);

      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: passwordController.text.trim(),
      );

      final uid = credential.user!.uid;

      final patientDoc = await FirebaseFirestore.instance
          .collection('patient_users')
          .doc(uid)
          .get();

      if (!patientDoc.exists) {
        await FirebaseAuth.instance.signOut();

        throw FirebaseAuthException(
          code: 'patient-not-found',
          message: 'Akun pasien tidak ditemukan',
        );
      }

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Login gagal';

      if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential' ||
          e.code == 'invalid-email') {
        message = 'Nomor telepon atau password salah';
      } else if (e.code == 'patient-not-found') {
        message = 'Akun pasien tidak ditemukan';
      } else if (e.code == 'too-many-requests') {
        message = 'Terlalu banyak percobaan login. Coba lagi nanti.';
      }

      _showMessage(message);
    } catch (e) {
      _showMessage('Terjadi kesalahan: $e');
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Informasi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _goToRegister() {
    FocusScope.of(context).unfocus();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const PatientSignupScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
  onWillPop: () async {
    await goBackSmooth();
    return false;
  },
    child: GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        FocusScope.of(context).unfocus();
      },

      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF5F7FA),
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 20,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 20,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 40,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: IconButton(
                            icon: const Icon(Icons.arrow_back),
                          onPressed: goBackSmooth,
                          ),
                        ),

                        const SizedBox(height: 10),

                        Image.asset(
                          'assets/logo_pustu.png',
                          height: 80,
                        ),

                        const SizedBox(height: 15),

                        const Text(
                          'Login Pasien',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Masuk menggunakan nomor telepon',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 35),

                        Form(
                          key: _formKey,
                          autovalidateMode: _isSubmitted
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              TextFormField(
                                controller: phoneController,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  labelText: 'Nomor Telepon',
                                  hintText: 'Contoh: 081234567890',
                                  prefixIcon:
                                      const Icon(Icons.phone_android),
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Nomor telepon harus diisi';
                                  }

                                  if (!PatientAuthHelper.isValidPhone(
                                    value,
                                  )) {
                                    return 'Nomor telepon tidak valid';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 18),

                              TextFormField(
                                controller: passwordController,
                                obscureText: isObscure,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  loginPatient();
                                },
                                decoration: InputDecoration(
                                  labelText: 'Password / PIN',
                                  prefixIcon:
                                      const Icon(Icons.lock_outline),
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
                                  filled: true,
                                  fillColor: Colors.white,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Password harus diisi';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 28),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed:
                                      isLoading ? null : loginPatient,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child:
                                              CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text(
                                          'LOGIN',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 14),

                              TextButton(
                                onPressed:
                                    isLoading ? null : _goToRegister,
                                child: const Text(
                                  'Belum punya akun? Daftar di sini',
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(),

                        const Padding(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            '© Pustu Hanua 2026',
                            style: TextStyle(
                              color: Colors.grey,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        ),
    ),
    );
  }
}
  