import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  State<AddPatientScreen> createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final nik = TextEditingController();
  final nama = TextEditingController();
  final jk = TextEditingController();
  final tgl = TextEditingController();
  final alamat = TextEditingController();

  Future<void> saveData() async {
    await FirebaseFirestore.instance.collection('patients').add({
      'nik': nik.text,
      'nama': nama.text,
      'jk': jk.text,
      'tgl': tgl.text,
      'alamat': alamat.text,
    });

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
                  "TAMBAH DATA PASIEN",
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
                onPressed: saveData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text("SIMPAN"),
              )
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