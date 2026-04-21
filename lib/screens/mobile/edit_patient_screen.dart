import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditPatientScreen extends StatefulWidget {
  final String id;
  final Map data;

  const EditPatientScreen({super.key, required this.id, required this.data});

  @override
  State<EditPatientScreen> createState() => _EditPatientScreenState();
}

class _EditPatientScreenState extends State<EditPatientScreen> {
  late TextEditingController nik;
  late TextEditingController nama;
  late TextEditingController jk;
  late TextEditingController tgl;
  late TextEditingController alamat;

  bool isLoading = false;

  @override
  void initState() {
    nik = TextEditingController(text: widget.data['nik']);
    nama = TextEditingController(text: widget.data['nama']);
    jk = TextEditingController(text: widget.data['jk']);
    tgl = TextEditingController(text: widget.data['tgl']);
    alamat = TextEditingController(text: widget.data['alamat']);
    super.initState();
  }

  /// 🔥 POPUP SUCCESS
  void showSuccess(String text) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle, color: Colors.green, size: 60),
            const SizedBox(height: 10),
            Text(text, textAlign: TextAlign.center),
          ],
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pop(context); // close dialog
      Navigator.pop(context); // back
    });
  }

  /// UPDATE
  Future<void> updateData() async {
    if (nama.text.isEmpty || nik.text.isEmpty) return;

    setState(() => isLoading = true);

    await FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.id)
        .update({
      'nik': nik.text,
      'nama': nama.text,
      'jk': jk.text,
      'tgl': tgl.text,
      'alamat': alamat.text,
    });

    setState(() => isLoading = false);

    showSuccess("Data berhasil diupdate");
  }

  /// DELETE
  Future<void> deleteData() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Konfirmasi"),
        content: const Text("Yakin hapus data ini?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Batal"),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseFirestore.instance
                  .collection('patients')
                  .doc(widget.id)
                  .delete();

              Navigator.pop(context);
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Data berhasil dihapus")),
              );
            },
            child: const Text("Hapus"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: ListView(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),

              const Center(
                child: Text(
                  "EDIT DATA PASIEN",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),

              const Divider(),

              _input("NIK", nik),
              _input("Nama", nama),
              _input("Jenis Kelamin", jk),
              _input("Tanggal Lahir", tgl),
              _input("Alamat", alamat),

              const SizedBox(height: 20),

              /// UPDATE BUTTON
              ElevatedButton(
                onPressed: isLoading ? null : updateData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text("UPDATE"),
              ),

              const SizedBox(height: 10),

              /// DELETE BUTTON
              ElevatedButton(
                onPressed: deleteData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("HAPUS"),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input(String label, TextEditingController c) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: TextField(
        controller: c,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.grey[300],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}