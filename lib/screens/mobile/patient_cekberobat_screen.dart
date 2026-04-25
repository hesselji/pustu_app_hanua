import 'package:flutter/material.dart';

class PatientCheckScreen extends StatelessWidget {
  const PatientCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            /// 🔹 HEADER
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  const Spacer(),

                  _logo("Kemenkes"),
                  const SizedBox(width: 10),
                  _logo("Pustu"),

                  const Spacer(),

                  const Text(
                    "Pustu Hanua",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            const Divider(),

            /// 🔹 CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 10),

                    /// 🔹 TITLE
                    const Center(
                      child: Text(
                        "LIHAT DAFTAR BEROBAT",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔹 INPUT NIK
                    const Text("Masukkan NIK:"),
                    const SizedBox(height: 10),
                    _inputBox(),

                    const SizedBox(height: 20),

                    /// 🔹 INPUT TANGGAL
                    const Text("Masukkan Tanggal Berobat:"),
                    const SizedBox(height: 10),
                    _inputBox(),

                    const SizedBox(height: 20),

                    /// 🔹 BUTTON KIRIM
                    GestureDetector(
                      onTap: () {
                        // TODO: logic cek data
                      },
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text(
                            "KIRIM",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// 🔹 HASIL / DETAIL
                    Container(
                      width: double.infinity,
                      height: 250,
                      color: Colors.grey[300],
                      child: const Center(
                        child: Text("DETAIL BEROBAT"),
                      ),
                    ),

                    const SizedBox(height: 40),

                    /// 🔹 FOOTER
                    const Center(
                      child: Text(
                        "COPYRIGHT BY ....",
                        style: TextStyle(fontSize: 12),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔸 LOGO
  Widget _logo(String text) {
    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.image, size: 18, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(text, style: const TextStyle(fontSize: 8)),
      ],
    );
  }

  /// 🔸 INPUT BOX (placeholder)
  Widget _inputBox() {
    return Container(
      width: double.infinity,
      height: 50,
      color: Colors.grey[300],
    );
  }
}  