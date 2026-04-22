import 'package:flutter/material.dart';
import '../mobile/login_screen.dart';

class WebHomeScreen extends StatelessWidget {
  const WebHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          /// 🔹 NAVBAR
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            child: Row(
              children: const [
                Icon(Icons.local_hospital, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text(
                  "Pustu Hanua",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 BODY
          Expanded(
            child: Row(
              children: [
                /// 🔸 LEFT CONTENT
                Expanded(
                  flex: 5,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 80),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Sistem Informasi\nPelayanan Kesehatan",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            height: 1.3,
                          ),
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Platform digital untuk membantu perawat\n"
                          "mengelola data pasien dan layanan kesehatan\n"
                          "secara efisien dan modern.",
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),

                        const SizedBox(height: 40),

                        /// 🔥 BUTTON LOGIN
                        _HoverButton(
                          text: "Login Perawat",
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                /// 🔸 RIGHT ILLUSTRATION
                Expanded(
                  flex: 5,
                  child: Container(
                    margin: const EdgeInsets.all(40),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.local_hospital,
                        size: 150,
                        color: Colors.green.shade400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          /// 🔹 FOOTER
          const Padding(
            padding: EdgeInsets.only(bottom: 15),
            child: Text(
              "© Pustu Hanua 2026",
              style: TextStyle(color: Colors.grey),
            ),
          )
        ],
      ),
    );
  }
}

/// 🔥 CUSTOM BUTTON HOVER (WEB FEEL)
class _HoverButton extends StatefulWidget {
  final String text;
  final VoidCallback onTap;

  const _HoverButton({required this.text, required this.onTap});

  @override
  State<_HoverButton> createState() => _HoverButtonState();
}

class _HoverButtonState extends State<_HoverButton> {
  bool isHover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHover = true),
      onExit: (_) => setState(() => isHover = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        transform: Matrix4.translationValues(0, isHover ? -3 : 0, 0),
        child: GestureDetector(
          onTap: widget.onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 35, vertical: 18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
              ),
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: isHover ? 20 : 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}