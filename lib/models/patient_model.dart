class PatientModel {
  String? id;
  String nik;
  String nama;
  String jk;
  String tgl;
  String alamat;
  String agama;
  String pekerjaan;
  String pendidikan;
  String status;
  String usia;

  PatientModel({
    this.id,
    required this.nik,
    required this.nama,
    required this.jk,
    required this.tgl,
    required this.alamat,
    required this.agama,
    required this.pekerjaan,
    required this.pendidikan,
    required this.status,
    required this.usia,
  });

  factory PatientModel.fromMap(Map<String, dynamic> data, String id) {
    return PatientModel(
      id: id,
      nik: data['nik'] ?? "",
      nama: data['nama'] ?? "",
      jk: data['jk'] ?? "",
      tgl: data['tgl'] ?? "",
      alamat: data['alamat'] ?? "",
      agama: data['agama'] ?? "",
      pekerjaan: data['pekerjaan'] ?? "",
      pendidikan: data['pendidikan'] ?? "",
      status: data['status'] ?? "",
      usia: data['usia'] ?? "",
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'nik': nik,
      'nama': nama,
      'jk': jk,
      'tgl': tgl,
      'alamat': alamat,
      'agama': agama,
      'pekerjaan': pekerjaan,
      'pendidikan': pendidikan,
      'status': status,
      'usia': usia,
    };
  }
}