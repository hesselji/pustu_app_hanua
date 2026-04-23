import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'web_patient_screen.dart';
import 'web_medical_record_screen.dart';

class WebPerawatDashboard extends StatefulWidget {
  const WebPerawatDashboard({super.key});

  @override
  State<WebPerawatDashboard> createState() => _WebPerawatDashboardState();
}

class _WebPerawatDashboardState extends State<WebPerawatDashboard> {
  int selectedMenu = 0;

  final menus = [
    {"icon": Icons.dashboard, "title": "Dashboard"},
    {"icon": Icons.people, "title": "Pasien"},
    {"icon": Icons.medical_services, "title": "Rekam Medis"},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),

      body: Row(
        children: [
          /// 🔥 SIDEBAR
          Container(
            width: 230,
            decoration: const BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black12, blurRadius: 10)
              ],
            ),
            child: Column(
              children: [
                const SizedBox(height: 25),

                /// LOGO
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo_pustu.png", height: 35),
                    const SizedBox(width: 10),
                    const Text(
                      "Pustu Hanua",
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                /// MENU
                ...List.generate(menus.length, (index) {
                  final m = menus[index];
                  final active = selectedMenu == index;

                  return InkWell(
                    onTap: () => setState(() => selectedMenu = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.green.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            m["icon"] as IconData,
                            color: active ? Colors.green : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            m["title"] as String,
                            style: TextStyle(
                              color: active ? Colors.green : Colors.black,
                              fontWeight: active
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          )
                        ],
                      ),
                    ),
                  );
                }),

                const Spacer(),

                /// LOGOUT
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout"),
                  onTap: () async {
                    await FirebaseAuth.instance.signOut();
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),

          /// 🔥 MAIN CONTENT
          Expanded(
            child: Column(
              children: [
                /// 🔝 TOP BAR
                Container(
                  height: 70,
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        menus[selectedMenu]["title"] as String,
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications_none),
                      const SizedBox(width: 20),
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person, color: Colors.white),
                      ),
                    ],
                  ),
                ),

                /// CONTENT
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 🔥 SWITCH CONTENT
  Widget _buildContent() {
    switch (selectedMenu) {
      case 0:
        return _dashboardContent();
      case 1:
        return const WebPatientScreen();
      case 2:
        return const WebMedicalRecordScreen();
      default:
        return const Center(child: Text("Coming Soon"));
    }
  }

  /// 🔥 DASHBOARD UI (UPGRADED)
  Widget _dashboardContent() {
    return Column(
      children: [
        /// 🔹 STAT CARDS
        Row(
          children: [
            _statCard("Total Pasien", Icons.people, "patients"),
            _statCard("Rekam Medis", Icons.medical_services, "medical_records"),
            _todayCard(),
          ],
        ),

        const SizedBox(height: 25),

        /// 🔹 AKTIVITAS
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(color: Colors.black12, blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Aktivitas Terbaru",
                    style:
                        TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),

                const SizedBox(height: 20),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("patients")
                        .limit(5)
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child: CircularProgressIndicator());
                      }

                      final data = snapshot.data!.docs;

                      return ListView.builder(
                        itemCount: data.length,
                        itemBuilder: (context, i) {
                          final doc = data[i];

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor: Colors.green,
                                  child: Icon(Icons.person,
                                      color: Colors.white),
                                ),
                                const SizedBox(width: 10),
                                Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text(doc['nama']),
                                    Text("NIK ${doc['nik']}",
                                        style: const TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey)),
                                  ],
                                )
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }

  /// 🔥 STAT CARD MODERN
  Widget _statCard(String title, IconData icon, String collection) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.green.withOpacity(0.3),
              blurRadius: 10,
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(collection)
                  .snapshots(),
              builder: (context, snapshot) {
                int total = snapshot.data?.docs.length ?? 0;

                return Text(
                  "$total",
                  style: const TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            const SizedBox(height: 5),
            Text(title,
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  /// 🔥 TODAY CARD (BONUS)
  Widget _todayCard() {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
          boxShadow: const [
            BoxShadow(color: Colors.black12, blurRadius: 10)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Icon(Icons.today, color: Colors.green),
            SizedBox(height: 10),
            Text(
              "—",
              style: TextStyle(
                  fontSize: 26, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5),
            Text("Kunjungan Hari Ini",
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}