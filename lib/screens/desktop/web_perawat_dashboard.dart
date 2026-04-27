import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'web_patient_screen.dart';
import 'web_medical_record_screen.dart';
import 'web_home_screen.dart';

class WebPerawatDashboard extends StatefulWidget {
  const WebPerawatDashboard({super.key});

  @override
  State<WebPerawatDashboard> createState() =>
      _WebPerawatDashboardState();
}

class _WebPerawatDashboardState
    extends State<WebPerawatDashboard> {
  int selectedMenu = 0;

  DateTime? selectedDate;

  final menus = [
    {"icon": Icons.dashboard, "title": "Dashboard"},
    {"icon": Icons.people, "title": "Pasien"},
    {"icon": Icons.medical_services, "title": "Rekam Medis"},
  ];

  String formatDate(DateTime date) {
    return "${date.day} - ${date.month} - ${date.year}";
  }

  Future<void> pickDate() async {
    DateTime now = DateTime.now();

    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: now,
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

    Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const WebHomeScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Row(
        children: [

          /// SIDEBAR
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

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo_pustu.png",
                        height: 35),
                    const SizedBox(width: 10),
                    const Text(
                      "Pustu Hanua",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                ...List.generate(menus.length, (index) {
                  final m = menus[index];
                  final active = selectedMenu == index;

                  return InkWell(
                    onTap: () =>
                        setState(() => selectedMenu = index),
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: active
                            ? Colors.green.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius:
                            BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            m["icon"] as IconData,
                            color: active
                                ? Colors.green
                                : Colors.grey,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            m["title"] as String,
                            style: TextStyle(
                              color: active
                                  ? Colors.green
                                  : Colors.black,
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

                ListTile(
                  leading:
                      const Icon(Icons.logout, color: Colors.red),
                  title: const Text("Logout"),
                  onTap: logout,
                ),
              ],
            ),
          ),

          /// MAIN
          Expanded(
            child: Column(
              children: [
                Container(
                  height: 70,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        menus[selectedMenu]["title"]
                            as String,
                        style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      const Icon(Icons.notifications_none),
                      const SizedBox(width: 20),
                      const CircleAvatar(
                        backgroundColor: Colors.green,
                        child: Icon(Icons.person,
                            color: Colors.white),
                      ),
                    ],
                  ),
                ),

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

  /// 🔥 DASHBOARD
  Widget _dashboardContent() {
    final now = DateTime.now();
    final selected = selectedDate ?? now;
    final selectedString = formatDate(selected);

    String greeting;
    if (now.hour < 12) {
      greeting = "Selamat pagi ☀️";
    } else if (now.hour < 18) {
      greeting = "Selamat siang 🌤️";
    } else {
      greeting = "Selamat malam 🌙";
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Text(
          greeting,
          style: const TextStyle(
              fontSize: 22, fontWeight: FontWeight.bold),
        ),

        const SizedBox(height: 5),

        const Text(
          "Kelola pendaftaran pasien dengan cepat dan tepat",
          style: TextStyle(color: Colors.grey),
        ),

        const SizedBox(height: 25),

        /// STAT
        Row(
          children: [
            _statCard("Total Pasien", Icons.people, "patients"),
            _statCard("Rekam Medis",
                Icons.medical_services, "medical_records"),
            _todayPatientCard(),
          ],
        ),

        const SizedBox(height: 20),

        /// 🔥 INFORMASI PELAYANAN (TANPA KONFIRMASI)
        _serviceStatusCard(),

        const SizedBox(height: 25),

        /// PENDAFTARAN
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                    color: Colors.black12, blurRadius: 10)
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Row(
                  children: [
                    const Text(
                      "Pendaftaran Pasien",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16),
                    ),
                    const Spacer(),

                    ElevatedButton.icon(
                      onPressed: pickDate,
                      icon: const Icon(Icons.date_range),
                      label: Text(selectedString),
                    ),

                    if (selectedDate != null)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(
                              () => selectedDate = null);
                        },
                      )
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection("registrations")
                        .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                            child:
                                CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      final filtered = docs.where((doc) {
                        return doc['tanggal'] ==
                            selectedString;
                      }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                            child: Text(
                                "Tidak ada pendaftaran"));
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final doc = filtered[i];
                          final d = doc.data()
                              as Map<String, dynamic>;

                          final status =
                              d['status'] ?? "pending";

                          return Container(
                            margin: const EdgeInsets.only(
                                bottom: 12),
                            padding:
                                const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(12),
                              color: Colors.grey.shade50,
                            ),
                            child: Row(
                              children: [
                                const CircleAvatar(
                                  backgroundColor:
                                      Colors.green,
                                  child: Icon(Icons.person,
                                      color: Colors.white),
                                ),

                                const SizedBox(width: 12),

                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment
                                            .start,
                                    children: [
                                      Text(
                                        d['patient_name'] ??
                                            "-",
                                        style: const TextStyle(
                                            fontWeight:
                                                FontWeight
                                                    .bold),
                                      ),
                                      Text(
                                          "NIK ${d['nik'] ?? '-'}"),
                                    ],
                                  ),
                                ),

                                Text(
                                  status.toUpperCase(),
                                  style: TextStyle(
                                    color: status ==
                                            "accepted"
                                        ? Colors.green
                                        : status ==
                                                "rejected"
                                            ? Colors.red
                                            : Colors.orange,
                                  ),
                                ),

                                const SizedBox(width: 10),

                                if (status == "pending") ...[
                                  ElevatedButton(
                                    style: ElevatedButton
                                        .styleFrom(
                                            backgroundColor:
                                                Colors.green),
                                    onPressed: () async {
                                      await FirebaseFirestore
                                          .instance
                                          .collection(
                                              "registrations")
                                          .doc(doc.id)
                                          .update({
                                        "status": "accepted"
                                      });
                                    },
                                    child:
                                        const Text("Terima"),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton
                                        .styleFrom(
                                            backgroundColor:
                                                Colors.red),
                                    onPressed: () async {
                                      await FirebaseFirestore
                                          .instance
                                          .collection(
                                              "registrations")
                                          .doc(doc.id)
                                          .update({
                                        "status": "rejected"
                                      });
                                    },
                                    child:
                                        const Text("Tolak"),
                                  ),
                                ]
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
        ),
      ],
    );
  }

  /// 🔥 SERVICE STATUS
  Widget _serviceStatusCard() {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('service_status')
          .doc('status')
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final data =
            snapshot.data!.data() as Map<String, dynamic>?;

        bool isAvailable =
            data?['isAvailable'] ?? true;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: isAvailable
                  ? [Colors.green.shade50, Colors.white]
                  : [Colors.red.shade50, Colors.white],
            ),
          ),
          child: Row(
            children: [

              Icon(Icons.medical_services,
                  color: isAvailable
                      ? Colors.green
                      : Colors.red),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  isAvailable
                      ? "Perawat Tersedia"
                      : "Perawat Tidak Tersedia",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAvailable
                        ? Colors.green
                        : Colors.red,
                  ),
                ),
              ),

              Switch(
                value: isAvailable,
                onChanged: (value) async {
                  await FirebaseFirestore.instance
                      .collection('service_status')
                      .doc('status')
                      .set({
                    'isAvailable': value,
                  });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _statCard(
      String title, IconData icon, String collection) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [
              Colors.green.shade400,
              Colors.green.shade600
            ],
          ),
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection(collection)
                  .snapshots(),
              builder: (context, snapshot) {
                int total =
                    snapshot.data?.docs.length ?? 0;

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
                style:
                    const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _todayPatientCard() {
    final today = DateTime.now();
    final todayString =
        "${today.day} - ${today.month} - ${today.year}";

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            const Icon(Icons.today,
                color: Colors.green),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection("patients")
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData)
                  return const Text("-");

                final docs = snapshot.data!.docs;

                final count = docs.where((doc) {
                  return doc['tgl'] == todayString;
                }).length;

                return Text(
                  "$count",
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                );
              },
            ),

            const SizedBox(height: 5),
            const Text(
              "Pasien Hari Ini",
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}