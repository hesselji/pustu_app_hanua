import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            /// 🔹 HEADER CUSTOM
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  /// BACK BUTTON
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),

                  /// LOGO KEMENKES
                  _logo(),

                  const SizedBox(width: 8),

                  /// LOGO BAKTI HUSADA
                  _logo(),

                  const Spacer(),

                  /// TITLE
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
                child: Column(
                  children: [
                    const SizedBox(height: 20),

                    /// TITLE
                    const Text(
                      "ABOUT US",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// DESKRIPSI
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      padding: const EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        "Aplikasi Puskesmas Pembantu (Pustu) Hanua di Kabupaten Pulang Pisau ini dirancang sebagai sistem pencatatan digital dan arsip dokumen untuk membantu perawat dalam mengelola data pelayanan kesehatan. Aplikasi ini memungkinkan proses pencatatan data pasien, penyimpanan arsip, serta pengelolaan informasi pelayanan dilakukan secara lebih terstruktur dan terdokumentasi dengan baik. Selain itu, pasien tetap dapat melakukan pendaftaran dan melihat daftar berobat sebagai bagian dari layanan yang terintegrasi. Dengan adanya aplikasi ini, pengelolaan data menjadi lebih rapi, aman, dan mudah diakses.",
                        textAlign: TextAlign.justify,
                      ),
                    ),

                    const SizedBox(height: 30),

                    /// INFORMASI PENGEMBANG
                    const Text(
                      "INFORMASI PENGEMBANG",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),

                    const SizedBox(height: 20),

                    /// 🔹 DEVELOPER (SEJAJAR)
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Expanded(
                            child: DeveloperItem(
                              name1: "Hessel Josef",
                              name2: "Imanuel",
                              email: "hesseljosef",
                            ),
                          ),
                          Expanded(
                            child: DeveloperItem(
                              name1: "Mahendra",
                              name2: "Juliansen",
                              email: "mahendrajuliansen",
                            ),
                          ),
                          Expanded(
                            child: DeveloperItem(
                              name1: "Bagus Rian",
                              name2: "Bahari",
                              email: "bagusrianbahari",
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),

            /// 🔹 FOOTER
            const Padding(
              padding: EdgeInsets.only(bottom: 10),
              child: Text(
                "COPYRIGHT © 2026 PUSTU HANUA",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔸 LOGO (placeholder)
  Widget _logo() {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.image, size: 16, color: Colors.grey),
    );
  }
}

/// 🔸 DEVELOPER ITEM
class DeveloperItem extends StatelessWidget {
  final String name1;
  final String name2;
  final String email;

  const DeveloperItem({
    super.key,
    required this.name1,
    required this.name2,
    required this.email,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// FOTO
        CircleAvatar(
          radius: 30,
          backgroundColor: Colors.grey[300],
          child: const Icon(Icons.person, size: 30, color: Colors.grey),
        ),

        const SizedBox(height: 8),

        /// NAMA (BOLD)
        Text(
          name1,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
        Text(
          name2,
          style: const TextStyle(fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),

        const SizedBox(height: 5),

        /// EMAIL (2 BARIS)
        Text(
          email,
          style: const TextStyle(fontSize: 10),
          textAlign: TextAlign.center,
        ),
        const Text(
          "@mhs.eng.upr.ac.id",
          style: TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
