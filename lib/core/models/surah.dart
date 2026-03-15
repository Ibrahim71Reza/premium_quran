class Surah {
  final int id;
  final String surahNo;
  final String nameAr;
  final String nameEn;
  final String nameBn;
  final String fileName;

  Surah({
    required this.id,
    required this.surahNo,
    required this.nameAr,
    required this.nameEn,
    required this.nameBn,
    required this.fileName,
  });

  // This factory takes the JSON from your file and turns it into a Dart Object
  factory Surah.fromJson(Map<String, dynamic> json) {
    return Surah(
      id: json['id'],
      surahNo: json['surahNo'],
      nameAr: json['nameAr'],
      nameEn: json['nameEn'],
      nameBn: json['nameBn'],
      fileName: json['fileName'],
    );
  }
}