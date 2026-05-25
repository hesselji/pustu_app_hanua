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
            child: Container(
              margin: const EdgeInsets.all(20),
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "KELOLA INFORMASI PELAYANAN",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 30),

                  /// 🔥 SWITCH (FIXED)
                  Switch(
                    value: isAvailable,

                    /// 🔥 MATERIAL 3 STYLE
                    thumbColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.green;
                        }
                        return Colors.grey;
                      },
                    ),
                    trackColor: WidgetStateProperty.resolveWith<Color?>(
                      (states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.green.withOpacity(0.5);
                        }
                        return Colors.grey.withOpacity(0.3);
                      },
                    ),

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

                  /// 🔥 STATUS TEXT
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      isAvailable ? "TERSEDIA" : "TIDAK TERSEDIA",
                      key: ValueKey(isAvailable),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: isAvailable ? Colors.green : Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}