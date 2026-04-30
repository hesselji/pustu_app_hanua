import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PatientRegisterScreen extends StatefulWidget {
  const PatientRegisterScreen({super.key});

  @override
  State<PatientRegisterScreen> createState() =>
      _PatientRegisterScreenState();
}

class _PatientRegisterScreenState
    extends State<PatientRegisterScreen> {

  /// 🔥 CONTROLLER INPUT
  final TextEditingController namaController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController keluhanController =
      TextEditingController();

  /// 🔥 STATE
  DateTime? selectedDate;
  String selectedLayanan = "";
  TimeOfDay? selectedTime;

  /// Time Picker
  Future<void> pilihJam() async {
    TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
   );

  if (picked != null) {
    setState(() {
      selectedTime = picked;
      });
    }
  }

  /// 🔥 DATE PICKER
  Future<void> pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// Tambah Data
  Future<void> kirimData() async {
  if (namaController.text.isEmpty ||
      nikController.text.isEmpty ||
      keluhanController.text.isEmpty ||
      selectedDate == null ||
      selectedTime == null ||
      selectedLayanan.isEmpty) {

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Semua field harus diisi!"),
        backgroundColor: Colors.red,
      ),
    );
    return;
  }

  try {
    /// 🔥 GABUNGKAN TANGGAL + JAM
    DateTime finalDateTime = DateTime(
      selectedDate!.year,
      selectedDate!.month,
      selectedDate!.day,
      selectedTime!.hour,
      selectedTime!.minute,
    );

    await FirebaseFirestore.instance.collection('registrations').add({
      'patient_name': namaController.text,
      'nik': nikController.text,
      'keluhan': keluhanController.text,
      'tanggal': Timestamp.fromDate(finalDateTime),
      'layanan': selectedLayanan,
      'status': "Pending",
      'created_at': Timestamp.now(),
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Berhasil mendaftar!"),
        backgroundColor: Colors.green,
      ),
    );

    resetForm();

  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Gagal: $e"),
        backgroundColor: Colors.red,
      ),
    );
  }
}

  /// 🔥 RESET FORM
  void resetForm() {
    setState(() {
      nikController.clear();
      namaController.clear();
      keluhanController.clear();
      selectedDate = null;
      selectedTime = null;
      selectedLayanan = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [

            /// HEADER (tetap)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  _logo("Kemenkes"),
                  const SizedBox(width: 10),
                  _logo("Pustu"),
                  const Spacer(),
                  const Text("Pustu Hanua",
                      style: TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),

            const Divider(),

            /// CONTENT
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [

                    const SizedBox(height: 10),

                    const Center(
                      child: Text(
                        "FORM DAFTAR BEROBAT",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),

                    const SizedBox(height: 20),

                    /// 🔥 STATUS FIRESTORE (tetap)
                    StreamBuilder<DocumentSnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection('service_status')
                          .doc('status')
                          .snapshots(),
                      builder: (context, snapshot) {

                        if (!snapshot.hasData) {
                          return const CircularProgressIndicator();
                        }

                        final data = snapshot.data!.data()
                            as Map<String, dynamic>?;

                        bool isAvailable = data?['isAvailable'] ?? true;

                        return Row(
                          children: [
                            Expanded(
                              child: _box(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    const Text("Status Petugas"),
                                    Container(
                                      width: 20,
                                      height: 20,
                                      decoration: BoxDecoration(
                                        color: isAvailable
                                            ? Colors.green
                                            : Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _box(
                                child: Text(
                                  isAvailable
                                      ? "Tersedia"
                                      : "Tidak Tersedia",
                                  style: TextStyle(
                                    color: isAvailable
                                        ? Colors.green
                                        : Colors.red,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),

                    const SizedBox(height: 20),
                    const Divider(),

                    /// 🔥 DATA PASIEN
                    /// NAMA
                    const Text("Nama Pasien"),
                    const SizedBox(height: 10),
                    _inputField(controller: namaController),

                    const SizedBox(height: 10),

                    /// NIK
                    const Text("NIK"),
                    const SizedBox(height: 10),
                    _inputField(controller: nikController),

                    const SizedBox(height: 20),
                    const Divider(),

                    /// 🔥 KELUHAN
                    const Text("Keluhan Pasien"),
                    const SizedBox(height: 10),
                    _inputField(
                        controller: keluhanController, height: 80),

                    const SizedBox(height: 20),
                    const Divider(),

                    /// 🔥 TANGGAL
                    const Text("Tanggal Berobat"),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: pilihTanggal,
                      child: Container(
                        height: 50,
                        color: Colors.grey[300],
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          selectedDate == null
                              ? "Pilih tanggal"
                              : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    /// 🔥 JAM
                    GestureDetector(
                      onTap: pilihJam,
                      child: Container(
                        height: 50,
                        color: Colors.grey[300],
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          selectedTime == null
                              ? "Pilih jam"
                              : "${selectedTime!.hour}:${selectedTime!.minute.toString().padLeft(2, '0')}",
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    const Divider(),

                    /// 🔥 JENIS LAYANAN
                    const Center(child: Text("Pilih Jenis Layanan")),

                    const SizedBox(height: 15),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.spaceEvenly,
                      children: [
                        _button("Home Care"),
                        _button("Pustu Visit"),
                      ],
                    ),

                    const SizedBox(height: 30),
                    const Divider(),

                    /// BUTTON KIRIM
                    GestureDetector(
                      onTap: kirimData,
                      child: Container(
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Center(
                          child: Text(
                            "KIRIM",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                     
                    
                    /// 🔥 RESET
                    GestureDetector(
                      onTap: resetForm,
                      child: Container(
                        width: double.infinity,
                        height: 40,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Text("BERSIHKAN"),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    const Center(
                      child: Text("COPYRIGHT BY ....",
                          style: TextStyle(fontSize: 12)),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔸 INPUT FIELD
  Widget _inputField(
      {required TextEditingController controller, double height = 50}) {
    return Container(
      height: height,
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: TextField(
        controller: controller,
        decoration: const InputDecoration(border: InputBorder.none),
      ),
    );
  }

  /// 🔸 BUTTON PILIH LAYANAN
  Widget _button(String text) {
    bool isSelected = selectedLayanan == text;

    return GestureDetector(
      onTap: () {
        setState(() {
          selectedLayanan = text;
        });
      },
      child: Container(
        width: 120,
        height: 40,
        decoration: BoxDecoration(
          color: isSelected ? Colors.green : Colors.grey[300],
          borderRadius: BorderRadius.circular(5),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }

  /// 🔸 LOGO
  Widget _logo(String text) {
    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(8),
          ),
          child:
              const Icon(Icons.image, size: 18, color: Colors.grey),
        ),
        const SizedBox(height: 2),
        Text(text, style: const TextStyle(fontSize: 8)),
      ],
    );
  }

  /// 🔸 BOX STATUS
  Widget _box({required Widget child}) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      color: Colors.grey[300],
      child: Center(child: child),
    );
  }
}