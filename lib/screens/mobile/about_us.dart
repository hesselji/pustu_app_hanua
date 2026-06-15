import 'package:flutter/material.dart';

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

@override
  Widget build(BuildContext context) {
    return GestureDetector(
  onTap: () {
    FocusScope.of(context).unfocus();
  },
  child: Scaffold(
    body: SafeArea(
      child: Column(
        children: [

  /// 🔥 HEADER MODERN
  Container(
    margin: const EdgeInsets.all(15),
    padding: const EdgeInsets.symmetric(
      horizontal: 15,
      vertical: 18,
    ),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(25),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Row(
      children: [

        /// 🔙 BACK BUTTON
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            Navigator.pop(context);
          },
          child: const Icon(Icons.arrow_back),
        ),

        const SizedBox(width: 15),

        /// 🔥 LOGO KIRI
        Image.asset(
          "assets/logo_kemenkes.png",
          width: 45,
          height: 45,
        ),

        const SizedBox(width: 15),

        /// 🔥 TEXT TENGAH
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [

              Text(
                "Pustu Hanua",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              SizedBox(height: 4),

              Text(
                "Layanan Kesehatan",
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),

        /// 🔥 LOGO KANAN
        Image.asset(
          "assets/logo_pustu.png",
          width: 45,
          height: 45,
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
                              email: "hesseljosef@gmail.com",
                              image: "assets/hessel.jpeg",
                            ),
                          ),
                          Expanded(
                            child: DeveloperItem(
                              name1: "Mahendra",
                              name2: "Juliansen",
                              email: "m357439@gmail.com",
                              image: "assets/mahen.jpeg",
                            ),
                          ),
                          Expanded(
                            child: DeveloperItem(
                              name1: "Bagus Rian",
                              name2: "Bahari",
                              email: "magusrian09@gmail.com",
                              image: "assets/bagus.jpeg",
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
    )
  );
}
}

/// 🔸 DEVELOPER ITEM
class DeveloperItem extends StatelessWidget {
  final String name1;
  final String name2;
  final String email;
  final String image;

  const DeveloperItem({
    super.key,
    required this.name1,
    required this.name2,
    required this.email,
    required this.image,
  });

@override
  Widget build(BuildContext context) {
    return Column(
      children: [
        /// FOTO
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.green,
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              image,
              fit: BoxFit.cover,
            ),
          ),
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
          "",
          style: TextStyle(fontSize: 10, color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
