import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../services/patient_auth_helper.dart';
import 'patient_home_screen.dart';

class PatientSignupScreen extends StatefulWidget {
  const PatientSignupScreen({super.key});

  @override
  State<PatientSignupScreen> createState() => _PatientSignupScreenState();
}

class _PatientSignupScreenState extends State<PatientSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool isLoading = false;
  bool isObscure = true;
  bool isConfirmObscure = true;
  bool _isSubmitted = false;

  @override
  void initState() {
    super.initState();

    namaController.addListener(_validateAfterSubmit);
    nikController.addListener(_validateAfterSubmit);
    phoneController.addListener(_validateAfterSubmit);
    passwordController.addListener(_validateAfterSubmit);
    confirmPasswordController.addListener(_validateAfterSubmit);
  }

  void _validateAfterSubmit() {
    if (_isSubmitted) {
      _formKey.currentState?.validate();
      setState(() {});
    }
  }

  @override
  void dispose() {
    namaController.removeListener(_validateAfterSubmit);
    nikController.removeListener(_validateAfterSubmit);
    phoneController.removeListener(_validateAfterSubmit);
    passwordController.removeListener(_validateAfterSubmit);
    confirmPasswordController.removeListener(_validateAfterSubmit);

    namaController.dispose();
    nikController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  Future<void> registerPatient() async {
    setState(() {
      _isSubmitted = true;
    });

    if (!_formKey.currentState!.validate()) return;

    FocusScope.of(context).unfocus();
    setState(() => isLoading = true);

    try {
      final phone = PatientAuthHelper.normalizePhone(phoneController.text);
      final email = PatientAuthHelper.phoneToEmail(phone);
      final password = passwordController.text.trim();

      final existing = await FirebaseFirestore.instance
          .collection('patient_users')
          .where('phone', isEqualTo: phone)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        throw FirebaseAuthException(
          code: 'phone-already-used',
          message: 'Nomor telepon sudah terdaftar',
        );
      }

      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final uid = credential.user!.uid;

      await FirebaseFirestore.instance
          .collection('patient_users')
          .doc(uid)
          .set({
        'uid': uid,
        'nama': namaController.text.trim(),
        'nik': nikController.text.trim(),
        'phone': phone,
        'email_internal': email,
        'role': 'pasien',
        'created_at': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Akun pasien berhasil dibuat'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const PatientHomeScreen()),
        (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = 'Registrasi gagal';

      if (e.code == 'email-already-in-use' ||
          e.code == 'phone-already-used') {
        message = 'Nomor telepon sudah terdaftar';
      } else if (e.code == 'weak-password') {
        message = 'Password minimal 6 karakter';
      } else if (e.code == 'invalid-email') {
        message = 'Format akun tidak valid';
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                            onPressed: () {
                              FocusScope.of(context).unfocus();
                              Navigator.pop(context);
                            },
                          ),
                        ),

                        const SizedBox(height: 5),

                        const Icon(
                          Icons.person_add_alt_1,
                          size: 70,
                          color: Colors.green,
                        ),

                        const SizedBox(height: 10),

                        const Text(
                          'Daftar Akun Pasien',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Buat akun untuk mengakses layanan pasien',
                          style: TextStyle(color: Colors.grey),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 28),

                        Form(
                          key: _formKey,
                          autovalidateMode: _isSubmitted
                              ? AutovalidateMode.onUserInteraction
                              : AutovalidateMode.disabled,
                          child: Column(
                            children: [
                              _inputField(
                                controller: namaController,
                                label: 'Nama Lengkap',
                                icon: Icons.person_outline,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Nama harus diisi';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              _inputField(
                                controller: nikController,
                                label: 'NIK',
                                icon: Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'NIK harus diisi';
                                  }

                                  if (value.trim().length != 16) {
                                    return 'NIK harus 16 digit';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              _inputField(
                                controller: phoneController,
                                label: 'Nomor Telepon',
                                hint: 'Contoh: 081234567890',
                                icon: Icons.phone_android,
                                keyboardType: TextInputType.phone,
                                textInputAction: TextInputAction.next,
                                validator: (value) {
                                  if (value == null ||
                                      value.trim().isEmpty) {
                                    return 'Nomor telepon harus diisi';
                                  }

                                  if (!PatientAuthHelper.isValidPhone(
                                      value)) {
                                    return 'Nomor telepon tidak valid';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: passwordController,
                                obscureText: isObscure,
                                textInputAction: TextInputAction.next,
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

                                  if (value.length < 6) {
                                    return 'Password minimal 6 karakter';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 16),

                              TextFormField(
                                controller: confirmPasswordController,
                                obscureText: isConfirmObscure,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  registerPatient();
                                },
                                decoration: InputDecoration(
                                  labelText:
                                      'Konfirmasi Password / PIN',
                                  prefixIcon:
                                      const Icon(Icons.lock_reset),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      isConfirmObscure
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        isConfirmObscure =
                                            !isConfirmObscure;
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
                                    return 'Konfirmasi password harus diisi';
                                  }

                                  if (value != passwordController.text) {
                                    return 'Konfirmasi password tidak sama';
                                  }

                                  return null;
                                },
                              ),

                              const SizedBox(height: 28),

                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  onPressed: isLoading
                                      ? null
                                      : registerPatient,
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
                                          'DAFTAR',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              TextButton(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        FocusScope.of(context).unfocus();
                                        Navigator.pop(context);
                                      },
                                child: const Text(
                                  'Sudah punya akun? Login di sini',
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
    );
  }

  Widget _inputField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? hint,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}