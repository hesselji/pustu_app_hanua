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

  @override
  void initState() {
    nik = TextEditingController(text: widget.data['nik']);
    nama = TextEditingController(text: widget.data['nama']);
    jk = TextEditingController(text: widget.data['jk']);
    tgl = TextEditingController(text: widget.data['tgl']);
    alamat = TextEditingController(text: widget.data['alamat']);
    super.initState();
  }

  Future<void> updateData() async {
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

    Navigator.pop(context);
  }

  Future<void> deleteData() async {
    await FirebaseFirestore.instance
        .collection('patients')
        .doc(widget.id)
        .delete();

    Navigator.pop(context);
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

              ElevatedButton(
                onPressed: updateData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("UPDATE"),
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: deleteData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
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