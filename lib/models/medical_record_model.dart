class MedicalRecord {
  String id;
  String tanggal;
  String keluhan;

  String tdSistolik;
  String tdDiastolik;
  String nadi;
  String suhu;

  String kolesterol;
  String gulaDarah;
  String asamUrat;

  String diagnosa;
  String terapi;

  String alergiObat;
  String alergiMakanan;

  MedicalRecord({
    required this.id,
    required this.tanggal,
    required this.keluhan,
    required this.tdSistolik,
    required this.tdDiastolik,
    required this.nadi,
    required this.suhu,
    required this.kolesterol,
    required this.gulaDarah,
    required this.asamUrat,
    required this.diagnosa,
    required this.terapi,
    required this.alergiObat,
    required this.alergiMakanan,
  });

  Map<String, dynamic> toMap() {
    return {
      "tanggal": tanggal,
      "keluhan": keluhan,
      "td_sistolik": tdSistolik,
      "td_diastolik": tdDiastolik,
      "nadi": nadi,
      "suhu": suhu,
      "kolesterol": kolesterol,
      "gula_darah": gulaDarah,
      "asam_urat": asamUrat,
      "diagnosa": diagnosa,
      "terapi": terapi,
      "alergi_obat": alergiObat,
      "alergi_makanan": alergiMakanan,
    };
  }
}