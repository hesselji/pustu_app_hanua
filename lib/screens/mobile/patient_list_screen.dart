import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_patient_screen.dart';
import 'edit_patient_screen.dart';
import 'patient_detail_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientListScreen extends StatefulWidget {
  const PatientListScreen({super.key});

  @override
  State<PatientListScreen> createState() => _PatientListScreenState();
}

class _PatientListScreenState extends State<PatientListScreen> {
  void showErrorDialog(String message) {
    showDialog(
      context: context,

      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: Row(
              children: const [
                Icon(Icons.error, color: Colors.red),
                SizedBox(width: 10),
                Text("Validasi Gagal"),
              ],
            ),

            content: Text(message),

            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text("Mengerti"),
              ),
            ],
          ),
    );
  }

  void showSuccessDialog(String message) {
    showDialog(
      context: context,

      builder:
          (_) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),

            title: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green),
                SizedBox(width: 10),
                Text("Berhasil"),
              ],
            ),

            content: Text(message),

            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),

                onPressed: () {
                  Navigator.pop(context);
                },

                child: const Text("OK"),
              ),
            ],
          ),
    );
  }

  String searchText = "";

  void showDeleteDialog(String id) {
    final confirmController = TextEditingController();

    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    bool obscure = true;

    bool check1 = false;
    bool check2 = false;
    bool check3 = false;

    showDialog(
      context: context,

      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return AlertDialog(
              title: const Text("Verifikasi Penghapusan"),

              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    const Icon(
                      Icons.warning_amber_rounded,
                      color: Colors.red,
                      size: 60,
                    ),

                    const SizedBox(height: 15),

                    const Text(
                      "Tindakan ini sensitif dan akan tercatat dalam audit sistem.",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// LAYER 1
                    TextField(
                      controller: confirmController,

                      decoration: const InputDecoration(
                        labelText: "Ketik HAPUS",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// LAYER 2 EMAIL
                    TextField(
                      controller: emailController,

                      decoration: const InputDecoration(
                        labelText: "Email Admin",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 15),

                    /// PASSWORD
                    TextField(
                      controller: passwordController,
                      obscureText: obscure,

                      decoration: InputDecoration(
                        labelText: "Password Admin",
                        border: const OutlineInputBorder(),

                        suffixIcon: IconButton(
                          icon: Icon(
                            obscure ? Icons.visibility_off : Icons.visibility,
                          ),

                          onPressed: () {
                            setModal(() {
                              obscure = !obscure;
                            });
                          },
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// LAYER 3
                    CheckboxListTile(
                      value: check1,

                      onChanged: (v) {
                        setModal(() {
                          check1 = v!;
                        });
                      },

                      title: const Text(
                        "Saya memahami tindakan ini tercatat dalam audit sistem",
                      ),
                    ),

                    CheckboxListTile(
                      value: check2,

                      onChanged: (v) {
                        setModal(() {
                          check2 = v!;
                        });
                      },

                      title: const Text(
                        "Saya bertanggung jawab atas tindakan ini",
                      ),
                    ),

                    CheckboxListTile(
                      value: check3,

                      onChanged: (v) {
                        setModal(() {
                          check3 = v!;
                        });
                      },

                      title: const Text(
                        "Saya yakin penghapusan data diperlukan",
                      ),
                    ),
                  ],
                ),
              ),

              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Batal"),
                ),

                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),

                  onPressed: () async {
                    /// VALIDASI CHECKBOX
                    if (!check1 || !check2 || !check3) {
                      showErrorDialog(
                        "Semua pernyataan wajib dicentang terlebih dahulu.",
                      );

                      return;
                    }

                    try {
                      /// VALIDASI KETIK HAPUS
                      if (confirmController.text != "HAPUS") {
                        showErrorDialog("Konfirmasi HAPUS tidak valid");

                        return;
                      }

                      final user = FirebaseAuth.instance.currentUser;

                      if (user == null) return;

                      final credential = EmailAuthProvider.credential(
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );

                      await user.reauthenticateWithCredential(credential);

                      /// SOFT DELETE

                      await FirebaseFirestore.instance
                          .collection("patients")
                          .doc(id)
                          .update({
                            "is_deleted": true,
                            "deleted_at": FieldValue.serverTimestamp(),
                            "deleted_by": user.email,
                          });

                      if (!context.mounted) return;

                      Navigator.pop(context);

                      showSuccessDialog("Data Berhasil Dihapus");
                    } catch (e) {
                      showErrorDialog(
                        "Autentikasi admin gagal.\n\nPeriksa kembali email dan password.",
                      );
                    }
                  },
                  icon: const Icon(Icons.delete),

                  label: const Text("Hapus"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),

      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Kelola Data Pasien",
          style: TextStyle(color: Colors.black),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddPatientScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),

      body: Column(
        children: [
          const SizedBox(height: 10),

          /// 🔍 SEARCH
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 6,
                  ),
                ],
              ),
              child: TextField(
                onChanged: (v) => setState(() => searchText = v.toLowerCase()),
                decoration: const InputDecoration(
                  icon: Icon(Icons.search),
                  hintText: "Cari nama pasien...",
                  border: InputBorder.none,
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// 📋 LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance.collection('patients').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final data = snapshot.data!.docs;

                /// 🔍 FILTER
                final filtered =
                    data.where((doc) {
                      final pasien = doc.data() as Map<String, dynamic>;

                      if (pasien['is_deleted'] == true) {
                        return false;
                      }
                      final nama = doc['nama'].toString().toLowerCase();
                      return nama.contains(searchText);
                    }).toList();

                /// 🔥 SORT A-Z (INI KUNCI FIX)
                filtered.sort((a, b) {
                  final namaA = (a['nama'] ?? "").toString().toLowerCase();
                  final namaB = (b['nama'] ?? "").toString().toLowerCase();
                  return namaA.compareTo(namaB);
                });

                if (filtered.isEmpty) {
                  return const Center(child: Text("Tidak ada data"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, i) {
                    final doc = filtered[i];
                    final d = doc.data() as Map;

                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => PatientDetailScreen(data: d),
                          ),
                        );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.04),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.green[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person,
                                color: Colors.green,
                              ),
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    d['nama'] ?? "-",
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    "NIK ${d['nik'] ?? '-'}",
                                    style: TextStyle(color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),

                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blue,
                                  ),

                                  onPressed: () {
                                    final confirmController =
                                        TextEditingController();

                                    final emailController =
                                        TextEditingController();

                                    final passwordController =
                                        TextEditingController();

                                    bool obscure = true;

                                    bool check1 = false;
                                    bool check2 = false;
                                    bool check3 = false;

                                    showDialog(
                                      context: context,

                                      builder: (_) {
                                        return StatefulBuilder(
                                          builder: (context, setModal) {
                                            return AlertDialog(
                                              title: const Text(
                                                "Verifikasi Edit Data Pasien",
                                              ),

                                              content: SingleChildScrollView(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,

                                                  children: [
                                                    const Icon(
                                                      Icons.edit_note,
                                                      color: Colors.orange,
                                                      size: 60,
                                                    ),

                                                    const SizedBox(height: 15),

                                                    TextField(
                                                      controller:
                                                          confirmController,

                                                      decoration:
                                                          const InputDecoration(
                                                            labelText:
                                                                "Ketik EDIT",
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                    ),

                                                    const SizedBox(height: 15),

                                                    TextField(
                                                      controller:
                                                          emailController,

                                                      decoration:
                                                          const InputDecoration(
                                                            labelText:
                                                                "Email Admin",
                                                            border:
                                                                OutlineInputBorder(),
                                                          ),
                                                    ),

                                                    const SizedBox(height: 15),

                                                    TextField(
                                                      controller:
                                                          passwordController,
                                                      obscureText: obscure,

                                                      decoration: InputDecoration(
                                                        labelText:
                                                            "Password Admin",
                                                        border:
                                                            const OutlineInputBorder(),

                                                        suffixIcon: IconButton(
                                                          icon: Icon(
                                                            obscure
                                                                ? Icons
                                                                    .visibility_off
                                                                : Icons
                                                                    .visibility,
                                                          ),

                                                          onPressed: () {
                                                            setModal(() {
                                                              obscure =
                                                                  !obscure;
                                                            });
                                                          },
                                                        ),
                                                      ),
                                                    ),

                                                    const SizedBox(height: 20),

                                                    CheckboxListTile(
                                                      value: check1,
                                                      onChanged: (v) {
                                                        setModal(() {
                                                          check1 = v!;
                                                        });
                                                      },
                                                      title: const Text(
                                                        "Saya memahami perubahan akan tercatat",
                                                      ),
                                                    ),

                                                    CheckboxListTile(
                                                      value: check2,
                                                      onChanged: (v) {
                                                        setModal(() {
                                                          check2 = v!;
                                                        });
                                                      },
                                                      title: const Text(
                                                        "Saya bertanggung jawab atas perubahan data",
                                                      ),
                                                    ),

                                                    CheckboxListTile(
                                                      value: check3,
                                                      onChanged: (v) {
                                                        setModal(() {
                                                          check3 = v!;
                                                        });
                                                      },
                                                      title: const Text(
                                                        "Saya yakin perubahan data diperlukan",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),

                                              actions: [
                                                TextButton(
                                                  onPressed:
                                                      () => Navigator.pop(
                                                        context,
                                                      ),
                                                  child: const Text("Batal"),
                                                ),

                                                ElevatedButton(
                                                  onPressed: () async {
                                                    /// VALIDASI CHECKBOX
                                                    if (!check1 ||
                                                        !check2 ||
                                                        !check3) {
                                                      showErrorDialog(
                                                        "Semua pernyataan wajib dicentang terlebih dahulu.",
                                                      );

                                                      return;
                                                    }

                                                    try {
                                                      /// VALIDASI KETIK EDIT
                                                      if (confirmController
                                                              .text !=
                                                          "EDIT") {
                                                        showErrorDialog(
                                                          "Konfirmasi EDIT tidak valid",
                                                        );

                                                        return;
                                                      }

                                                      final user =
                                                          FirebaseAuth
                                                              .instance
                                                              .currentUser;

                                                      if (user == null) return;

                                                      final credential =
                                                          EmailAuthProvider.credential(
                                                            email:
                                                                emailController
                                                                    .text
                                                                    .trim(),

                                                            password:
                                                                passwordController
                                                                    .text
                                                                    .trim(),
                                                          );

                                                      await user
                                                          .reauthenticateWithCredential(
                                                            credential,
                                                          );

                                                      if (!context.mounted)
                                                        return;

                                                      Navigator.pop(context);
                                                      showSuccessDialog(
                                                        "DATA BERHASIL DIEDIT",
                                                      );
                                                      Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder:
                                                              (_) =>
                                                                  EditPatientScreen(
                                                                    id: doc.id,
                                                                    data: d,
                                                                  ),
                                                        ),
                                                      );
                                                    } catch (e) {
                                                      showErrorDialog(
                                                        "Autentikasi admin gagal.\n\nPeriksa kembali email dan password.",
                                                      );
                                                    }
                                                  },

                                                  child: const Text("Lanjut"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                    );
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => showDeleteDialog(doc.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
