import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PerawatKelolaDiagnosisScreen extends StatefulWidget {
  const PerawatKelolaDiagnosisScreen({super.key});

  @override
  State<PerawatKelolaDiagnosisScreen> createState() =>
      _PerawatKelolaDiagnosisScreenState();
}

class _PerawatKelolaDiagnosisScreenState
    extends State<PerawatKelolaDiagnosisScreen> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  final Color primaryGreen = const Color(0xFF1B7F3A);
  final Color darkGreen = const Color(0xFF0E4D2C);
  final Color background = const Color(0xFFF5F7FA);

  final TextEditingController searchController = TextEditingController();

  String searchText = "";
  bool isSaving = false;

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String normalizeText(String value) {
    return value.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  Future<bool> isDuplicateDiagnosis(String nama, {String? ignoreDocId}) async {
    final namaLower = normalizeText(nama).toLowerCase();

    final snapshot =
        await firestore
            .collection("disease_master")
            .where("nama_lower", isEqualTo: namaLower)
            .get();

    for (final doc in snapshot.docs) {
      final data = doc.data();

      if (ignoreDocId != null && doc.id == ignoreDocId) continue;
      if (data["is_deleted"] == true) continue;

      return true;
    }

    return false;
  }

  Future<bool> showDiagnosisSecurityDialog({
    required String actionWord,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) async {
    final confirmController = TextEditingController();
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    bool obscure = true;
    bool check1 = false;
    bool check2 = false;
    bool check3 = false;
    bool processing = false;
    String errorMessage = "";

    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: color),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                    ),

                    const SizedBox(height: 18),

                    TextField(
                      controller: confirmController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: InputDecoration(
                        labelText: "Ketik $actionWord",
                        border: const OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

                    TextField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        labelText: "Email Admin",
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 14),

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

                    const SizedBox(height: 16),

                    CheckboxListTile(
                      value: check1,
                      onChanged:
                          processing
                              ? null
                              : (v) {
                                setModal(() {
                                  check1 = v ?? false;
                                });
                              },
                      title: const Text(
                        "Saya memahami tindakan ini akan mengubah master data diagnosis",
                      ),
                    ),

                    CheckboxListTile(
                      value: check2,
                      onChanged:
                          processing
                              ? null
                              : (v) {
                                setModal(() {
                                  check2 = v ?? false;
                                });
                              },
                      title: const Text(
                        "Saya bertanggung jawab atas perubahan data ini",
                      ),
                    ),

                    CheckboxListTile(
                      value: check3,
                      onChanged:
                          processing
                              ? null
                              : (v) {
                                setModal(() {
                                  check3 = v ?? false;
                                });
                              },
                      title: const Text("Saya yakin tindakan ini diperlukan"),
                    ),

                    if (errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            processing
                                ? null
                                : () {
                                  Navigator.pop(dialogContext, false);
                                },
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: color),
                        onPressed:
                            processing
                                ? null
                                : () async {
                                  setModal(() {
                                    errorMessage = "";
                                  });

                                  if (!check1 || !check2 || !check3) {
                                    setModal(() {
                                      errorMessage =
                                          "Semua pernyataan wajib dicentang.";
                                    });
                                    return;
                                  }

                                  if (confirmController.text
                                          .trim()
                                          .toUpperCase() !=
                                      actionWord) {
                                    setModal(() {
                                      errorMessage =
                                          "Konfirmasi $actionWord tidak valid.";
                                    });
                                    return;
                                  }

                                  final user =
                                      FirebaseAuth.instance.currentUser;

                                  if (user == null) {
                                    setModal(() {
                                      errorMessage =
                                          "Akun admin tidak ditemukan. Silakan login ulang.";
                                    });
                                    return;
                                  }

                                  setModal(() {
                                    processing = true;
                                  });

                                  try {
                                    final credential =
                                        EmailAuthProvider.credential(
                                          email: emailController.text.trim(),
                                          password:
                                              passwordController.text.trim(),
                                        );

                                    await user.reauthenticateWithCredential(
                                      credential,
                                    );

                                    if (!dialogContext.mounted) return;
                                    Navigator.pop(dialogContext, true);
                                  } catch (e) {
                                    setModal(() {
                                      processing = false;
                                      errorMessage =
                                          "Autentikasi admin gagal. Periksa email dan password.";
                                    });
                                  }
                                },
                        child:
                            processing
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  "Lanjut",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    confirmController.dispose();
    emailController.dispose();
    passwordController.dispose();

    return result ?? false;
  }

  Future<void> showFormDialog({String? docId, String initialNama = ""}) async {
    final controller = TextEditingController(text: initialNama);
    final isEdit = docId != null;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return StatefulBuilder(
          builder: (context, setModal) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(22),
              ),
              title: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      isEdit ? Icons.edit_rounded : Icons.add_rounded,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      isEdit ? "Edit Diagnosis" : "Tambah Diagnosis",
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: TextField(
                controller: controller,
                autofocus: true,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  labelText: "Nama penyakit / diagnosis",
                  hintText: "Contoh: Hipertensi",
                  filled: true,
                  fillColor: const Color(0xFFF5F7FA),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              actions: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed:
                            isSaving
                                ? null
                                : () {
                                  Navigator.pop(context);
                                },
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text("Batal"),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ElevatedButton(
                        onPressed:
                            isSaving
                                ? null
                                : () async {
                                  final nama = normalizeText(controller.text);

                                  if (nama.isEmpty) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                          "Nama diagnosis tidak boleh kosong",
                                        ),
                                        backgroundColor: Colors.red,
                                      ),
                                    );
                                    return;
                                  }

                                  setModal(() => isSaving = true);

                                  try {
                                    final duplicate =
                                        await isDuplicateDiagnosis(
                                          nama,
                                          ignoreDocId: docId,
                                        );

                                    if (duplicate) {
                                      if (!context.mounted) return;

                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Diagnosis tersebut sudah ada",
                                          ),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );

                                      setModal(() => isSaving = false);
                                      return;
                                    }

                                    if (isEdit) {
                                      final user =
                                          FirebaseAuth.instance.currentUser;

                                      await firestore
                                          .collection("disease_master")
                                          .doc(docId)
                                          .update({
                                            "nama": nama,
                                            "nama_lower": nama.toLowerCase(),
                                            "updated_at":
                                                FieldValue.serverTimestamp(),
                                            "updated_by_email":
                                                user?.email ?? "-",
                                            "updated_by_uid": user?.uid ?? "-",
                                          });
                                    } else {
                                      await firestore
                                          .collection("disease_master")
                                          .add({
                                            "nama": nama,
                                            "nama_lower": nama.toLowerCase(),
                                            "is_deleted": false,
                                            "created_at":
                                                FieldValue.serverTimestamp(),
                                            "updated_at":
                                                FieldValue.serverTimestamp(),
                                          });
                                    }

                                    if (!context.mounted) return;

                                    Navigator.pop(context);

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          isEdit
                                              ? "Diagnosis berhasil diperbarui"
                                              : "Diagnosis berhasil ditambahkan",
                                        ),
                                        backgroundColor: Colors.green,
                                      ),
                                    );
                                  } catch (e) {
                                    if (!context.mounted) return;

                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Gagal menyimpan: $e"),
                                        backgroundColor: Colors.red,
                                      ),
                                    );

                                    setModal(() => isSaving = false);
                                  }
                                },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child:
                            isSaving
                                ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                                : const Text(
                                  "Simpan",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        );
      },
    );

    isSaving = false;
  }

  Future<void> confirmDelete({
    required String docId,
    required String nama,
  }) async {
    final confirm = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.delete_rounded, color: Colors.red),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  "Hapus Diagnosis?",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Text(
            'Diagnosis "$nama" akan dihapus dari daftar pilihan rekam medis. Data rekam medis lama yang sudah memakai diagnosis ini tidak akan ikut terhapus.',
            style: const TextStyle(height: 1.4),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context, false),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text("Batal"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      "Hapus",
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final user = FirebaseAuth.instance.currentUser;

    await firestore.collection("disease_master").doc(docId).update({
      "is_deleted": true,
      "deleted_at": FieldValue.serverTimestamp(),
      "deleted_by_email": user?.email ?? "-",
      "deleted_by_uid": user?.uid ?? "-",
    });
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Diagnosis berhasil dihapus"),
        backgroundColor: Colors.green,
      ),
    );
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> filterDocs(
    List<QueryDocumentSnapshot<Map<String, dynamic>>> docs,
  ) {
    final filtered =
        docs.where((doc) {
          final data = doc.data();

          if (data["is_deleted"] == true) return false;

          final nama = (data["nama"] ?? "").toString().toLowerCase();

          return nama.contains(searchText.toLowerCase());
        }).toList();

    filtered.sort((a, b) {
      final namaA = (a.data()["nama"] ?? "").toString().toLowerCase();
      final namaB = (b.data()["nama"] ?? "").toString().toLowerCase();

      return namaA.compareTo(namaB);
    });

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: Colors.green,
        onPressed: () {
          showFormDialog();
        },
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Tambah",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _searchBox(),
                    const SizedBox(height: 18),
                    _diagnosisList(),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [darkGreen, primaryGreen, const Color(0xFF43A047)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.25),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          InkWell(
            onTap: () => Navigator.pop(context),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(Icons.arrow_back, color: Colors.white),
            ),
          ),
          const SizedBox(width: 15),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Image.asset("assets/logo_pustu.png", width: 40, height: 40),
          ),
          const SizedBox(width: 15),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Kelola Diagnosis",
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  "Daftar penyakit rekam medis",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _searchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextField(
        controller: searchController,
        onChanged: (value) {
          setState(() {
            searchText = value;
          });
        },
        decoration: const InputDecoration(
          icon: Icon(Icons.search_rounded, color: Colors.green),
          hintText: "Cari diagnosis...",
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _diagnosisList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: firestore.collection("disease_master").snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: CircularProgressIndicator(color: Colors.green),
            ),
          );
        }

        final docs = filterDocs(snapshot.data!.docs);

        if (docs.isEmpty) {
          return _emptyState();
        }

        return Column(
          children:
              docs.map((doc) {
                final data = doc.data();
                final nama = data["nama"] ?? "-";

                return _diagnosisCard(docId: doc.id, nama: nama);
              }).toList(),
        );
      },
    );
  }

  Widget _diagnosisCard({required String docId, required String nama}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.10),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.healing_rounded, color: Colors.green),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              nama,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          IconButton(
            onPressed: () async {
              final verified = await showDiagnosisSecurityDialog(
                actionWord: "EDIT",
                title: "Verifikasi Edit Diagnosis",
                description:
                    "Edit diagnosis termasuk tindakan sensitif karena memengaruhi daftar pilihan pada rekam medis.",
                icon: Icons.edit_note_rounded,
                color: Colors.orange,
              );

              if (!verified) return;

              showFormDialog(docId: docId, initialNama: nama);
            },
            icon: const Icon(Icons.edit_rounded, color: Colors.blue),
          ),
          IconButton(
            onPressed: () async {
              final verified = await showDiagnosisSecurityDialog(
                actionWord: "HAPUS",
                title: "Verifikasi Hapus Diagnosis",
                description:
                    "Diagnosis akan dihapus dari daftar pilihan rekam medis. Data rekam medis lama tidak ikut terhapus.",
                icon: Icons.warning_amber_rounded,
                color: Colors.red,
              );

              if (!verified) return;

              confirmDelete(docId: docId, nama: nama);
            },
            icon: const Icon(Icons.delete_rounded, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _emptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: Colors.grey.withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.healing_outlined,
              color: Colors.grey,
              size: 38,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            "Belum Ada Diagnosis",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 6),
          const Text(
            "Tambahkan daftar penyakit agar dapat dipilih pada rekam medis.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, height: 1.35),
          ),
        ],
      ),
    );
  }
}
