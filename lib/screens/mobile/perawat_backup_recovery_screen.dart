import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:cross_file/cross_file.dart';
import 'package:flutter/material.dart';

import '../../services/backup_api_service.dart';

class PerawatBackupRecoveryScreen extends StatefulWidget {
  const PerawatBackupRecoveryScreen({super.key});

  @override
  State<PerawatBackupRecoveryScreen> createState() =>
      _PerawatBackupRecoveryScreenState();
}

class _PerawatBackupRecoveryScreenState
    extends State<PerawatBackupRecoveryScreen> {
  final Color primaryGreen = const Color(0xFF1B7F3A);
  final Color darkGreen = const Color(0xFF0E4D2C);
  final Color softGreen = const Color(0xFFE8F5E9);
  final Color background = const Color(0xFFF5F7FA);

  bool isBackingUp = false;
  bool isRestoring = false;

  Map<String, dynamic>? selectedBackup;
  String selectedFileName = "";

  int previewTotalDocuments = 0;
  Map<String, dynamic> previewCollections = {};

  String formatDateTime(DateTime date) {
    return "${date.day}/${date.month}/${date.year} "
        "${date.hour.toString().padLeft(2, '0')}:"
        "${date.minute.toString().padLeft(2, '0')}";
  }

  Future<void> createBackup() async {
    setState(() {
      isBackingUp = true;
    });

    try {
      final response = await BackupApiService.createBackup();

      final backup = response['backup'] as Map<String, dynamic>;

      final fileName =
          (response['fileName'] ??
                  'cadangan_data_pustu_hanua_${DateTime.now().millisecondsSinceEpoch}.json')
              .toString();

      final jsonString = const JsonEncoder.withIndent('  ').convert(backup);
      final bytes = Uint8List.fromList(utf8.encode(jsonString));

      await Share.shareXFiles(
        [XFile.fromData(bytes, name: fileName, mimeType: 'application/json')],
        text:
            'File cadangan data Pustu Hanua. Simpan file ini di Google Drive, File Manager, atau penyimpanan aman lainnya.',
      );

      if (!mounted) return;

      showSuccessDialog(
        title: "Backup Berhasil",
        message:
            "File cadangan berhasil dibuat. Jika muncul pilihan aplikasi, pilih Google Drive atau File Manager agar file tersimpan dan mudah ditemukan kembali.",
      );
    } catch (e) {
      if (!mounted) return;

      showErrorDialog(title: "Backup Gagal", message: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isBackingUp = false;
        });
      }
    }
  }

  Future<void> pickBackupFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) return;

      final file = result.files.first;

      if (file.bytes == null) {
        showErrorDialog(
          title: "File Tidak Terbaca",
          message:
              "File cadangan tidak dapat dibaca. Silakan pilih file cadangan yang valid.",
        );
        return;
      }

      final rawText = utf8.decode(file.bytes!);
      final decoded = jsonDecode(rawText);

      if (decoded is! Map<String, dynamic>) {
        showErrorDialog(
          title: "File Tidak Valid",
          message: "Format file cadangan tidak sesuai.",
        );
        return;
      }

      if (decoded['app'] != 'pustu_hanua' ||
          decoded['documents'] is! List<dynamic>) {
        showErrorDialog(
          title: "File Tidak Valid",
          message:
              "File yang dipilih bukan file cadangan dari aplikasi Pustu Hanua.",
        );
        return;
      }

      final summary = decoded['summary'] as Map<String, dynamic>?;

      setState(() {
        selectedBackup = decoded;
        selectedFileName = file.name;
        previewTotalDocuments =
            summary?['total_documents'] ??
            (decoded['documents'] as List).length;
        previewCollections =
            (summary?['collections'] as Map<String, dynamic>?) ?? {};
      });
    } catch (e) {
      showErrorDialog(
        title: "Gagal Membaca File",
        message: "File cadangan tidak valid atau rusak.\n\n$e",
      );
    }
  }

  Future<void> confirmRestore() async {
    if (selectedBackup == null) {
      showErrorDialog(
        title: "Belum Ada File",
        message: "Silakan pilih file cadangan terlebih dahulu.",
      );
      return;
    }

    final confirmController = TextEditingController();
    bool checked = false;

    final confirm = await showDialog<bool>(
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
                      color: Colors.orange.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.restore_rounded,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      "Pulihkan Data?",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Sistem hanya akan mengisi data yang hilang. Data yang masih ada tidak akan ditimpa.",
                      style: TextStyle(height: 1.4),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F7FA),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        "Jumlah data dalam file cadangan: $previewTotalDocuments dokumen",
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 16),
                    CheckboxListTile(
                      value: checked,
                      onChanged: (value) {
                        setModal(() {
                          checked = value ?? false;
                        });
                      },
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        "Saya memahami bahwa recovery hanya mengembalikan data yang hilang.",
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: confirmController,
                      decoration: InputDecoration(
                        labelText: "Ketik PULIHKAN",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                    ),
                  ],
                ),
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
                        onPressed: () {
                          if (!checked ||
                              confirmController.text.trim() != "PULIHKAN") {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Centang pernyataan dan ketik PULIHKAN dengan benar.",
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          padding: const EdgeInsets.symmetric(vertical: 13),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          "Pulihkan",
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

    if (confirm == true) {
      await restoreBackup();
    }
  }

  Future<void> restoreBackup() async {
    if (selectedBackup == null) return;

    setState(() {
      isRestoring = true;
    });

    try {
      final response = await BackupApiService.restoreBackup(
        backup: selectedBackup!,
      );

      final summary = response['summary'] as Map<String, dynamic>? ?? {};

      final restored = summary['restored_documents'] ?? 0;
      final reactivated = summary['reactivated_soft_deleted_documents'] ?? 0;
      final skipped = summary['skipped_documents'] ?? 0;
      final failed = summary['failed_documents'] ?? 0;

      if (!mounted) return;

      showSuccessDialog(
        title: "Recovery Selesai",
        message:
            "Data yang benar-benar hilang dan dipulihkan: $restored\nData yang sebelumnya terhapus dari tampilan dan diaktifkan kembali: $reactivated\nData yang masih aktif dan dilewati: $skipped\nData gagal diproses: $failed",
      );
    } catch (e) {
      if (!mounted) return;

      showErrorDialog(title: "Recovery Gagal", message: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          isRestoring = false;
        });
      }
    }
  }

  void showSuccessDialog({required String title, required String message}) {
    showDialog(
      context: context,
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
                  color: Colors.green.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: Colors.green,
                ),
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
          content: Text(message, style: const TextStyle(height: 1.4)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  void showErrorDialog({required String title, required String message}) {
    showDialog(
      context: context,
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
                child: const Icon(Icons.error_rounded, color: Colors.red),
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
          content: Text(message, style: const TextStyle(height: 1.4)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Tutup"),
            ),
          ],
        );
      },
    );
  }

  String logTime(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return formatDateTime(timestamp.toDate());
    }

    return "-";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          children: [
            _header(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    _infoCard(),
                    const SizedBox(height: 18),
                    _backupCard(),
                    const SizedBox(height: 18),
                    _restoreCard(),
                    const SizedBox(height: 18),
                    _historyCard(),
                    const SizedBox(height: 30),
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
                  "Backup & Recovery",
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
                  "Cadangan dan pemulihan data",
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [softGreen, Colors.white],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.green.withOpacity(0.12)),
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.shield_rounded,
              color: Colors.green,
              size: 30,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Pusat Cadangan Data",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                ),
                SizedBox(height: 5),
                Text(
                  "Gunakan fitur ini untuk membuat file cadangan dan memulihkan data yang hilang tanpa menimpa data yang masih ada.",
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _backupCard() {
    return _mainCard(
      icon: Icons.backup_rounded,
      iconColor: Colors.blue,
      title: "Backup Data Sekarang",
      subtitle:
          "Membuat file cadangan data pasien, pendaftaran, rekam medis, akun pasien, dan informasi pelayanan.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _noteBox(
            icon: Icons.folder_rounded,
            color: Colors.blue,
            text:
                "File cadangan akan disimpan ke perangkat. Setelah itu, simpan file ke Google Drive atau penyimpanan aman lainnya.",
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isBackingUp ? null : createBackup,
              icon:
                  isBackingUp
                      ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                      : const Icon(Icons.download_rounded, color: Colors.white),
              label: Text(
                isBackingUp ? "MEMBUAT CADANGAN..." : "BUAT FILE CADANGAN",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                disabledBackgroundColor: Colors.blue.withOpacity(0.45),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _restoreCard() {
    return _mainCard(
      icon: Icons.restore_rounded,
      iconColor: Colors.orange,
      title: "Pulihkan Data",
      subtitle:
          "Pilih file cadangan untuk mengembalikan data yang hilang. Data yang masih ada tidak akan ditimpa.",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _noteBox(
            icon: Icons.warning_amber_rounded,
            color: Colors.orange,
            text:
                "Mode recovery aman: sistem hanya mengisi data yang hilang dan melewati data yang masih tersedia.",
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isRestoring ? null : pickBackupFile,
                  icon: const Icon(Icons.file_open_rounded),
                  label: const Text(
                    "PILIH FILE",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.orange,
                    side: BorderSide(color: Colors.orange.withOpacity(0.5)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed:
                      isRestoring || selectedBackup == null
                          ? null
                          : confirmRestore,
                  icon:
                      isRestoring
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                          : const Icon(
                            Icons.restore_page_rounded,
                            color: Colors.white,
                          ),
                  label: Text(
                    isRestoring ? "MEMULIHKAN..." : "PULIHKAN",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    disabledBackgroundColor: Colors.orange.withOpacity(0.35),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ),
          if (selectedBackup != null) ...[
            const SizedBox(height: 16),
            _previewBackupCard(),
          ],
        ],
      ),
    );
  }

  Widget _previewBackupCard() {
    final collectionEntries = previewCollections.entries.toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.orange.withOpacity(0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "File Cadangan Terpilih",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          Text(
            selectedFileName,
            style: const TextStyle(color: Colors.black54, fontSize: 12),
          ),
          const SizedBox(height: 12),
          _smallInfoRow(
            label: "Total data",
            value: "$previewTotalDocuments dokumen",
          ),
          const SizedBox(height: 8),
          if (collectionEntries.isNotEmpty)
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  collectionEntries.map((entry) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: Text(
                        "${entry.key}: ${entry.value}",
                        style: const TextStyle(
                          color: Colors.orange,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    );
                  }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _historyCard() {
    return _mainCard(
      icon: Icons.history_rounded,
      iconColor: Colors.green,
      title: "Riwayat Backup & Recovery",
      subtitle: "Menampilkan aktivitas backup dan recovery terakhir.",
      child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream:
            FirebaseFirestore.instance
                .collection("backup_logs")
                .orderBy("created_at", descending: true)
                .limit(5)
                .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Text(
              "Riwayat belum dapat ditampilkan.",
              style: TextStyle(color: Colors.grey),
            );
          }

          if (!snapshot.hasData) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: CircularProgressIndicator(color: Colors.green),
              ),
            );
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Text(
              "Belum ada riwayat backup atau recovery.",
              style: TextStyle(color: Colors.grey),
            );
          }

          return Column(
            children:
                docs.map((doc) {
                  final data = doc.data();
                  final type = data["type"] ?? "-";
                  final total = data["total_documents"] ?? 0;
                  final restored = data["restored_documents"];
                  final skipped = data["skipped_documents"];

                  final isBackup = type == "backup";

                  return Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding: const EdgeInsets.all(13),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F7FA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: (isBackup ? Colors.blue : Colors.orange)
                                .withOpacity(0.10),
                            borderRadius: BorderRadius.circular(13),
                          ),
                          child: Icon(
                            isBackup
                                ? Icons.backup_rounded
                                : Icons.restore_rounded,
                            color: isBackup ? Colors.blue : Colors.orange,
                            size: 21,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isBackup ? "Backup Data" : "Recovery Data",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                isBackup
                                    ? "Total $total dokumen • ${logTime(data["created_at"])}"
                                    : "Dipulihkan $restored • Dilewati $skipped • ${logTime(data["created_at"])}",
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
          );
        },
      ),
    );
  }

  Widget _mainCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.035),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(icon, color: iconColor, size: 28),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  Widget _noteBox({
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color.withOpacity(0.95),
                fontSize: 12,
                height: 1.35,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInfoRow({required String label, required String value}) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ],
    );
  }
}
