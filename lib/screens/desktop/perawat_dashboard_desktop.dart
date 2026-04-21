import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PerawatDashboardDesktop extends StatefulWidget {
  const PerawatDashboardDesktop({super.key});

  @override
  State<PerawatDashboardDesktop> createState() =>
      _PerawatDashboardDesktopState();
}

class _PerawatDashboardDesktopState
    extends State<PerawatDashboardDesktop> {
  String search = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [

          /// 🔹 SIDEBAR
          Container(
            width: 250,
            color: Colors.green[700],
            child: Column(
              children: const [
                SizedBox(height: 40),
                Icon(Icons.local_hospital, color: Colors.white, size: 60),
                SizedBox(height: 10),
                Text(
                  "Pustu Hanua",
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                Divider(color: Colors.white),

                ListTile(
                  leading: Icon(Icons.people, color: Colors.white),
                  title: Text("Data Pasien",
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),

          /// 🔹 CONTENT
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [

                  /// TITLE
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      "KELOLA DATA PASIEN",
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// SEARCH
                  TextField(
                    onChanged: (val) {
                      setState(() => search = val.toLowerCase());
                    },
                    decoration: InputDecoration(
                      hintText: "Cari nama pasien...",
                      prefixIcon: const Icon(Icons.search),
                      filled: true,
                      fillColor: Colors.grey[200],
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// TABLE
                  Expanded(
                    child: StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('patients')
                          .snapshots(),
                      builder: (context, snapshot) {
                        if (!snapshot.hasData) {
                          return const Center(
                              child: CircularProgressIndicator());
                        }

                        final data = snapshot.data!.docs.where((doc) {
                          final nama =
                              doc['nama'].toString().toLowerCase();
                          return nama.contains(search);
                        }).toList();

                        return SingleChildScrollView(
                          child: DataTable(
                            columns: const [
                              DataColumn(label: Text("Nama")),
                              DataColumn(label: Text("NIK")),
                              DataColumn(label: Text("JK")),
                              DataColumn(label: Text("Aksi")),
                            ],
                            rows: data.map((doc) {
                              return DataRow(cells: [
                                DataCell(Text(doc['nama'])),
                                DataCell(Text(doc['nik'])),
                                DataCell(Text(doc['jk'])),

                                /// ACTIONS
                                DataCell(Row(
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit,
                                          color: Colors.blue),
                                      onPressed: () {
                                        // bisa sambungkan ke edit screen nanti
                                      },
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete,
                                          color: Colors.red),
                                      onPressed: () async {
                                        await FirebaseFirestore.instance
                                            .collection('patients')
                                            .doc(doc.id)
                                            .delete();
                                      },
                                    ),
                                  ],
                                )),
                              ]);
                            }).toList(),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}