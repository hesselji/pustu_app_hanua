import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'web_patient_screen.dart';
import 'web_medical_record_screen.dart';
import 'web_home_screen.dart';

class WebPerawatDashboard extends StatefulWidget {
  const WebPerawatDashboard({super.key});

  @override
  State<WebPerawatDashboard> createState() => _WebPerawatDashboardState();
}

class _WebPerawatDashboardState extends State<WebPerawatDashboard> {
  int selectedMenu = 0;

  DateTime? selectedDate = DateTime.now();

  final menus = [
    {"icon": Icons.dashboard, "title": "Dashboard"},
    {"icon": Icons.people, "title": "Pasien"},
    {"icon": Icons.medical_services, "title": "Rekam Medis"},
  ];

  String formatDate(DateTime date) {
    return "${date.day} - ${date.month} - ${date.year}";
  }

  String formatTanggalIndo(DateTime dt) {
    return "${dt.day}/${dt.month}/${dt.year}";
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

  Future<void> confirmUpdate({
    required String docId,
    required String statusBaru,
  }) async {
    bool? result = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Konfirmasi"),
            content: Text("Yakin ingin mengubah status menjadi $statusBaru?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text("Ya"),
              ),
            ],
          ),
    );

    if (result == true) {
      await FirebaseFirestore.instance
          .collection("registrations")
          .doc(docId)
          .update({"status": statusBaru});
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const WebHomeScreen()),
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
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: Column(
              children: [
                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset("assets/logo_pustu.png", height: 35),
                    const SizedBox(width: 10),
                    const Text(
                      "Pustu Hanua",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 30),

                ...List.generate(menus.length, (index) {
                  final m = menus[index];
                  final active = selectedMenu == index;

                  return InkWell(
                    onTap: () => setState(() => selectedMenu = index),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color:
                            active
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
                              fontWeight:
                                  active ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),

                const Spacer(),

                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
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
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  color: Colors.white,
                  child: Row(
                    children: [
                      Text(
                        menus[selectedMenu]["title"] as String,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
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
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
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
            _rekamMedisCard(),
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
                BoxShadow(color: Colors.black12, blurRadius: 10),
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
                        fontSize: 16,
                      ),
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
                          setState(() => selectedDate = null);
                        },
                      ),
                  ],
                ),

                const SizedBox(height: 20),

                Expanded(
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        FirebaseFirestore.instance
                            .collection("registrations")
                            .orderBy("created_at", descending: true)
                            .snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      final docs = snapshot.data!.docs;

                      final filtered =
                          docs.where((doc) {
                            if (selectedDate == null) return true;

                            final data = doc.data() as Map<String, dynamic>;
                            if (data['tanggal'] == null) return false;

                            DateTime tgl =
                                (data['tanggal'] as Timestamp).toDate();

                            return tgl.day == selectedDate!.day &&
                                tgl.month == selectedDate!.month &&
                                tgl.year == selectedDate!.year;
                          }).toList();

                      if (filtered.isEmpty) {
                        return const Center(
                          child: Text("Tidak ada pendaftaran"),
                        );
                      }

                      return ListView.builder(
                        itemCount: filtered.length,
                        itemBuilder: (context, i) {
                          final doc = filtered[i];
                          final d = doc.data() as Map<String, dynamic>;

                          final status = (d['status'] ?? "Pending").toString();

                          Color statusColor;
                          switch (status.toLowerCase()) {
                            case "diterima":
                              statusColor = Colors.green;
                              break;
                            case "ditolak":
                              statusColor = Colors.red;
                              break;
                            default:
                              statusColor = Colors.orange;
                          }

                          DateTime jam =
                              (d['created_at'] as Timestamp).toDate();

                          return Container(
                            margin: const EdgeInsets.only(bottom: 14),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              color: Colors.white,
                              boxShadow: const [
                                BoxShadow(color: Colors.black12, blurRadius: 6),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                /// HEADER
                                Row(
                                  children: [
                                    const CircleAvatar(
                                      backgroundColor: Colors.green,
                                      child: Icon(
                                        Icons.person,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 12),

                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            d['patient_name'] ?? "-",
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text("NIK: ${d['nik']}"),
                                        ],
                                      ),
                                    ),

                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 5,
                                      ),
                                      decoration: BoxDecoration(
                                        color: statusColor.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        status,
                                        style: TextStyle(
                                          color: statusColor,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 10),

                                Text("Keluhan: ${d['keluhan']}"),
                                Text("Layanan: ${d['layanan']}"),

                                const SizedBox(height: 6),

                                Text(
                                  "Tanggal: ${formatTanggalIndo((d['tanggal'] as Timestamp).toDate())}",
                                  style: const TextStyle(color: Colors.grey),
                                ),

                                Text(
                                  "Jam: ${jam.hour}:${jam.minute.toString().padLeft(2, '0')}",
                                  style: const TextStyle(color: Colors.grey),
                                ),

                                const SizedBox(height: 12),

                                if (status.toLowerCase() == "pending") ...[
                                  Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.green,
                                          ),
                                          onPressed: () {
                                            confirmUpdate(
                                              docId: doc.id,
                                              statusBaru: "Diterima",
                                            );
                                          },
                                          child: const Text("Terima"),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.red,
                                          ),
                                          onPressed: () {
                                            confirmUpdate(
                                              docId: doc.id,
                                              statusBaru: "Ditolak",
                                            );
                                          },
                                          child: const Text("Tolak"),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
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
      stream:
          FirebaseFirestore.instance
              .collection('service_status')
              .doc('status')
              .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }

        final data = snapshot.data!.data() as Map<String, dynamic>?;

        bool isAvailable = data?['isAvailable'] ?? true;

        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors:
                  isAvailable
                      ? [Colors.green.shade50, Colors.white]
                      : [Colors.red.shade50, Colors.white],
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.medical_services,
                color: isAvailable ? Colors.green : Colors.red,
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Text(
                  isAvailable ? "Perawat Tersedia" : "Perawat Tidak Tersedia",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isAvailable ? Colors.green : Colors.red,
                  ),
                ),
              ),

              Switch(
                value: isAvailable,
                onChanged: (value) async {
                  await FirebaseFirestore.instance
                      .collection('service_status')
                      .doc('status')
                      .set({'isAvailable': value});
                },
              ),
            ],
          ),
        );
      },
    );
  }

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
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection(collection).snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("0", style: TextStyle(color: Colors.white));
                }

                final total = snapshot.data!.docs.length;

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
            Text(title, style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _rekamMedisCard() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 15),
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          gradient: LinearGradient(
            colors: [Colors.green.shade400, Colors.green.shade600],
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.medical_services, color: Colors.white),
            const SizedBox(height: 10),

         FutureBuilder<QuerySnapshot>(
  future: FirebaseFirestore.instance
      .collectionGroup("medical_records")
      .get(), // 🔥 ambil semua dulu
  builder: (context, snapshot) {
    if (!snapshot.hasData) {
      return const Text("0",
          style: TextStyle(color: Colors.white));
    }

    final docs = snapshot.data!.docs;

    /// 🔥 FILTER DI SINI (INI YANG BARU)
    final filtered = docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return data['is_deleted'] != true;
    }).toList();

    final total = filtered.length;

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
            const Text("Rekam Medis", style: TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }

  Widget _todayPatientCard() {
    final today = DateTime.now();

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.today, color: Colors.green),
            const SizedBox(height: 10),

            StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection("registrations")
                      .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Text("-");
                }

                final docs = snapshot.data!.docs;

                final count =
                    docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;
                      if (data['tanggal'] == null) return false;

                      DateTime tgl = (data['tanggal'] as Timestamp).toDate();

                      return tgl.day == today.day &&
                          tgl.month == today.month &&
                          tgl.year == today.year;
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
            const Text("Pasien Hari Ini", style: TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
