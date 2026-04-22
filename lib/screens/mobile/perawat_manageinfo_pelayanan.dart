import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InformasiPelayananScreen extends StatelessWidget {
  const InformasiPelayananScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Informasi Pelayanan"),
        backgroundColor: Colors.green,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: firestore
            .collection('service_status')
            .doc('status')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.data() as Map<String, dynamic>?;

          bool isAvailable = true;

          if (data != null && data.containsKey('isAvailable')) {
            isAvailable = data['isAvailable'];
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                const Text(
                  "KELOLA INFORMASI PELAYANAN",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 30),

                /// 🔥 TOGGLE
                Switch(
                  value: isAvailable,
                  activeColor: Colors.green,
                  onChanged: (value) async {
                    await firestore
                        .collection('service_status')
                        .doc('status')
                        .set({
                      'isAvailable': value,
                    });
                  },
                ),

                const SizedBox(height: 20),

                /// STATUS TEXT
                Text(
                  isAvailable ? "TERSEDIA" : "TIDAK TERSEDIA",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? Colors.green : Colors.red,
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