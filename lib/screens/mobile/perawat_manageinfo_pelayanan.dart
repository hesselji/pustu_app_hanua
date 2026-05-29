import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InformasiPelayananScreen extends StatelessWidget {
  const InformasiPelayananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      /// 🔥 APPBAR PUTIH KONSISTEN
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black),

        title: const Text(
          "Informasi Pelayanan",
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore
            .collection('service_status')
            .doc('status')
            .snapshots(),

        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          final data =
              snapshot.data!.data() as Map<String, dynamic>?;

          bool isAvailable = true;

          if (data != null &&
              data.containsKey('isAvailable')) {
            isAvailable = data['isAvailable'];
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),

            child: Column(
              children: [

                const SizedBox(height: 20),

                /// 🔥 HEADER CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(22),

                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),

                    gradient: LinearGradient(
                      colors: isAvailable
                          ? [
                              Colors.green.shade400,
                              Colors.green.shade600,
                            ]
                          : [
                              Colors.red.shade400,
                              Colors.red.shade600,
                            ],
                    ),

                    boxShadow: [
                      BoxShadow(
                        color: (isAvailable
                                ? Colors.green
                                : Colors.red)
                            .withOpacity(0.25),

                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      /// ICON
                      Container(
                        width: 75,
                        height: 75,

                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),

                        child: Icon(
                          isAvailable
                              ? Icons.health_and_safety
                              : Icons.close_rounded,

                          color: Colors.white,
                          size: 38,
                        ),
                      ),

                      const SizedBox(height: 18),

                      Text(
                        isAvailable
                            ? "Pelayanan Sedang Aktif"
                            : "Pelayanan Tidak Tersedia",

                        textAlign: TextAlign.center,

                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        isAvailable
                            ? "Informasi Pelayanan Ditampilkan 'Tersedia' Kepada Pasien"
                            : "Pasien Tetap Dapat Melakukan Pendaftaran Berobat, namun Informasi Ketidaktersediaan Pelayanan Akan Ditampilkan Kepada Pasien",

                        textAlign: TextAlign.center,

                        style: TextStyle(
                          color: Colors.white.withOpacity(0.9),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔥 CONTROL CARD
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(24),

                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),

                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),

                  child: Column(
                    children: [

                      Row(
                        children: [

                          Container(
                            padding: const EdgeInsets.all(12),

                            decoration: BoxDecoration(
                              color: Colors.green.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(14),
                            ),

                            child: const Icon(
                              Icons.settings,
                              color: Colors.green,
                            ),
                          ),

                          const SizedBox(width: 14),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,

                              children: [

                                Text(
                                  "Kelola Status Pelayanan",

                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                SizedBox(height: 4),

                                Text(
                                  "Aktifkan atau nonaktifkan layanan pendaftaran pasien.",

                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 13,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      /// 🔥 STATUS BOX
                      AnimatedContainer(
                        duration:
                            const Duration(milliseconds: 300),

                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),

                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.withOpacity(0.08)
                              : Colors.red.withOpacity(0.08),

                          borderRadius:
                              BorderRadius.circular(20),

                          border: Border.all(
                            color: isAvailable
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                          ),
                        ),

                        child: Row(
                          children: [

                            AnimatedContainer(
                              duration:
                                  const Duration(milliseconds: 300),

                              width: 14,
                              height: 14,

                              decoration: BoxDecoration(
                                color: isAvailable
                                    ? Colors.green
                                    : Colors.red,

                                shape: BoxShape.circle,

                                boxShadow: [
                                  BoxShadow(
                                    color: (isAvailable
                                            ? Colors.green
                                            : Colors.red)
                                        .withOpacity(0.4),

                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(width: 12),

                            Expanded(
                              child: Text(
                                isAvailable
                                    ? "Pelayanan tersedia untuk pasien"
                                    : "Pelayanan sedang dinonaktifkan",

                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: isAvailable
                                      ? Colors.green
                                      : Colors.red,
                                ),
                              ),
                            ),

                            /// 🔥 SWITCH PREMIUM
                            Switch(
                              value: isAvailable,

                              activeColor: Colors.white,
                              activeTrackColor: Colors.green,

                              inactiveThumbColor: Colors.white,
                              inactiveTrackColor:
                                  Colors.red.withOpacity(0.6),

                              onChanged: (value) async {

                                await firestore
                                    .collection(
                                        'service_status')
                                    .doc('status')
                                    .set({
                                  'isAvailable': value,
                                });
                              },
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      /// 🔥 STATUS TEXT
                      AnimatedSwitcher(
                        duration:
                            const Duration(milliseconds: 300),

                        child: Text(
                          isAvailable
                              ? "TERSEDIA"
                              : "TIDAK TERSEDIA",

                          key: ValueKey(isAvailable),

                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,

                            color: isAvailable
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}