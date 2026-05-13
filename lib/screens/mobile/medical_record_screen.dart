import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'add_medical_record_screen.dart';
import 'medical_record_detail_screen.dart';
import 'edit_medical_record_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalRecordScreen extends StatefulWidget {
  final String patientId;
  final String nama;
  final String nik;

  const MedicalRecordScreen({
    super.key,
    required this.patientId,
    required this.nama,
    required this.nik,
  });

  @override
  State<MedicalRecordScreen> createState() => _MedicalRecordScreenState();
}

class _MedicalRecordScreenState extends State<MedicalRecordScreen> {
  String selectedDate = "";

  /// 📅 PICK DATE
  Future<void> pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      String formatted =
          "${picked.day} ${_monthName(picked.month)} ${picked.year}";

      setState(() {
        selectedDate = formatted;
      });
    }
  }

  /// 🔹 BULAN
  String _monthName(int m) {
    const months = [
      "",
      "Jan",
      "Feb",
      "Mar",
      "Apr",
      "Mei",
      "Jun",
      "Jul",
      "Agu",
      "Sep",
      "Okt",
      "Nov",
      "Des",
    ];
    return months[m];
  }

  /// 🔥 PARSE TANGGAL STRING → DateTime
  DateTime parseTanggal(String tgl) {
    try {
      final parts = tgl.split(" ");
      int day = int.parse(parts[0]);
      int year = int.parse(parts[2]);

      int month =
          [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "Mei",
            "Jun",
            "Jul",
            "Agu",
            "Sep",
            "Okt",
            "Nov",
            "Des",
          ].indexOf(parts[1]) +
          1;

      return DateTime(year, month, day);
    } catch (e) {
      return DateTime(1900); // fallback
    }
  }

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

  /// 🔥 DELETE
  void showDeleteDialog(String recordId) {
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
                          .doc(widget.patientId)
                          .collection("medical_records")
                          .doc(recordId)
                          .update({
                            "is_deleted": true,
                            "deleted_at": FieldValue.serverTimestamp(),
                            "deleted_by": user.email,
                          });

                      if (!mounted) return;

                      Navigator.pop(context);

                      showSuccessDialog("Data rekam medis berhasil dihapus");
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
        title: const Text("Rekam Medis", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),

      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (_) => AddMedicalRecordScreen(patientId: widget.patientId),
            ),
          );
        },
      ),

      body: Column(
        children: [
          /// HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nama,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "NIK: ${widget.nik}",
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// FILTER
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GestureDetector(
              onTap: pickDate,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today),
                    const SizedBox(width: 10),
                    Text(selectedDate.isEmpty ? "Pilih tanggal" : selectedDate),
                    const Spacer(),
                    if (selectedDate.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          setState(() => selectedDate = "");
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          /// LIST
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream:
                  FirebaseFirestore.instance
                      .collection("patients")
                      .doc(widget.patientId)
                      .collection("medical_records")
                      .snapshots(), // 🔥 tanpa orderBy
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final docs = snapshot.data!.docs;

                /// FILTER + DELETE
                var filtered =
                    docs.where((doc) {
                      final data = doc.data() as Map<String, dynamic>;

                      if (data['is_deleted'] == true) return false;

                      final tgl = data['tanggal'] ?? "";

                      if (selectedDate.isEmpty) return true;
                      return tgl == selectedDate;
                    }).toList();

                /// 🔥 SORT DESCENDING
                filtered.sort((a, b) {
                  final da = parseTanggal(a['tanggal'] ?? "");
                  final db = parseTanggal(b['tanggal'] ?? "");
                  return db.compareTo(da);
                });

                if (filtered.isEmpty) {
                  return const Center(child: Text("Belum ada rekam medis"));
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) {
                    final doc = filtered[index];
                    final data = doc.data() as Map<String, dynamic>;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              color: Colors.green,
                            ),
                            const SizedBox(width: 12),

                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (_) => MedicalRecordDetailScreen(
                                            data: data,
                                            tanggal: data['tanggal'],
                                          ),
                                    ),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      data['tanggal'] ?? "-",
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Text(data['keluhan'] ?? "-"),
                                  ],
                                ),
                              ),
                            ),

                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                final confirmController =
                                    TextEditingController();

                                final emailController = TextEditingController();
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
                                            "Verifikasi Edit Rekam Medis",
                                          ),

                                          content: SingleChildScrollView(
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,

                                              children: [
                                                const Icon(
                                                  Icons.edit_note,
                                                  color: Colors.orange,
                                                  size: 60,
                                                ),

                                                const SizedBox(height: 15),

                                                TextField(
                                                  controller: confirmController,

                                                  decoration:
                                                      const InputDecoration(
                                                        labelText: "Ketik EDIT",
                                                        border:
                                                            OutlineInputBorder(),
                                                      ),
                                                ),

                                                const SizedBox(height: 15),

                                                TextField(
                                                  controller: emailController,

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
                                                    labelText: "Password Admin",
                                                    border:
                                                        const OutlineInputBorder(),

                                                    suffixIcon: IconButton(
                                                      icon: Icon(
                                                        obscure
                                                            ? Icons
                                                                .visibility_off
                                                            : Icons.visibility,
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
                                                  () => Navigator.pop(context),
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
                                                  if (confirmController.text !=
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
                                                            emailController.text
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

                                                  if (!mounted) return;

                                                  Navigator.pop(context);

                                                  showSuccessDialog(
                                                    "DATA BERHASIL DIEDIT",
                                                  );

                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder:
                                                          (
                                                            _,
                                                          ) => EditMedicalRecordScreen(
                                                            patientId:
                                                                widget
                                                                    .patientId,
                                                            recordId: doc.id,
                                                            data: data,
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
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                showDeleteDialog(doc.id);
                              },
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
