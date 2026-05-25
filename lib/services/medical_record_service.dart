import 'package:cloud_firestore/cloud_firestore.dart';

class MedicalRecordService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> addRecord(String patientId, Map<String, dynamic> data) async {
    await _firestore
        .collection("patients")
        .doc(patientId)
        .collection("medical_records")
        .add(data);
  }

  Stream<QuerySnapshot> getRecords(String patientId) {
    return _firestore
        .collection("patients")
        .doc(patientId)
        .collection("medical_records")
        .orderBy("tanggal", descending: true)
        .snapshots();
  }

  Future<void> deleteRecord(String patientId, String recordId) async {
    await _firestore
        .collection("patients")
        .doc(patientId)
        .collection("medical_records")
        .doc(recordId)
        .delete();
  }

  Future<void> updateRecord(
      String patientId, String recordId, Map<String, dynamic> data) async {
    await _firestore
        .collection("patients")
        .doc(patientId)
        .collection("medical_records")
        .doc(recordId)
        .update(data);
  }
}