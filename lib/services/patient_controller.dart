import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/patient_model.dart';

class PatientController {
  final CollectionReference patients =
      FirebaseFirestore.instance.collection('patients');

  Future<void> addPatient(PatientModel patient) async {
    await patients.add(patient.toMap());
  }

  Future<void> updatePatient(PatientModel patient) async {
    await patients.doc(patient.id).update(patient.toMap());
  }

  Future<void> deletePatient(String id) async {
    await patients.doc(id).delete();
  }
}