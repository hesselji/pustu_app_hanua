import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../services/notification_api_service.dart';

class InformasiPelayananScreen extends StatefulWidget {
  const InformasiPelayananScreen({super.key});

  @override
  State<InformasiPelayananScreen> createState() =>
      _InformasiPelayananScreenState();
}

class _InformasiPelayananScreenState extends State<InformasiPelayananScreen> {
  final firestore = FirebaseFirestore.instance;

  bool isUpdating = false;

  Future<void> updateServiceStatusAndNotify(bool value) async {
    if (isUpdating) return;

    setState(() {
      isUpdating = true;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      await firestore.collection('service_status').doc('status').set({
        'isAvailable': value,
        'updated_at': FieldValue.serverTimestamp(),
        'updated_by_email': user?.email,
        'updated_by_uid': user?.uid,
      }, SetOptions(merge: true));

      final title = value
          ? 'Pelayanan Pustu Hanua Tersedia'
          : 'Pelayanan Pustu Hanua Tidak Tersedia';

      final body = value
          ? 'Petugas Pustu Hanua sedang tersedia. Pasien dapat melakukan pendaftaran berobat melalui aplikasi.'
          : 'Petugas Pustu Hanua sedang tidak tersedia. Pendaftaran tetap dapat dilakukan, namun konfirmasi mungkin membutuhkan waktu lebih lama.';

      try {
        await NotificationApiService.sendToPatientTopic(
          title: title,
          body: body,
          data: {
            'type': 'service_status',
            'isAvailable': value.toString(),
          },
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              value
                  ? 'Status tersedia dan notifikasi berhasil dikirim'
                  : 'Status tidak tersedia dan notifikasi berhasil dikirim',
            ),
            backgroundColor: Colors.green,
          ),
        );
      } catch (notificationError) {
        debugPrint('Notifikasi gagal dikirim: $notificationError');

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Status berhasil diubah, tetapi notifikasi gagal dikirim: $notificationError',
            ),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      debugPrint('Gagal update status pelayanan: $e');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah status pelayanan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          isUpdating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

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
        stream: firestore.collection('service_status').doc('status').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(
                color: Colors.green,
              ),
            );
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          bool isAvailable = true;

          if (data != null && data.containsKey('isAvailable')) {
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
                        color: (isAvailable ? Colors.green : Colors.red)
                            .withOpacity(0.25),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
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
                            ? "Informasi pelayanan ditampilkan tersedia kepada pasien dan notifikasi akan dikirim saat status diperbarui."
                            : "Pasien tetap dapat melakukan pendaftaran berobat, namun informasi ketidaktersediaan pelayanan akan ditampilkan kepada pasien.",
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
                              crossAxisAlignment: CrossAxisAlignment.start,
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
                        duration: const Duration(milliseconds: 300),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 18,
                        ),
                        decoration: BoxDecoration(
                          color: isAvailable
                              ? Colors.green.withOpacity(0.08)
                              : Colors.red.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isAvailable
                                ? Colors.green.withOpacity(0.2)
                                : Colors.red.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          children: [
                            AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              width: 14,
                              height: 14,
                              decoration: BoxDecoration(
                                color: isAvailable ? Colors.green : Colors.red,
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

                            if (isUpdating)
                              const SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.green,
                                ),
                              )
                            else
                              Switch(
                                value: isAvailable,
                                activeColor: Colors.white,
                                activeTrackColor: Colors.green,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor:
                                    Colors.red.withOpacity(0.6),
                                onChanged: (value) async {
                                  await updateServiceStatusAndNotify(value);
                                },
                              ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 25),

                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 300),
                        child: Text(
                          isAvailable ? "TERSEDIA" : "TIDAK TERSEDIA",
                          key: ValueKey(isAvailable),
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                            color: isAvailable ? Colors.green : Colors.red,
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