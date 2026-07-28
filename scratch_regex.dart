import 'dart:core';

void main() {
  List<String> texts = [
    "12 Agustus 2026 Awal Kuliah",
    "12 - 14 Agustus 2026 Pendaftaran",
    "1 s.d 3 September 2026 Kegiatan A",
    "Kegiatan 1 Agustus 2024",
    "12, 13, 14 Juli Libur",
    "2026 Awal Kuliah",
    "Agustus 2026",
    "11	Juli	2026	Akhir Perkuliahan Semester Genap"
  ];

  final dateRegex = RegExp(r'^(\d{1,2}(?:\s*(?:-|s\.?/?d\.?)\s*\d{1,2}|\s*,\s*\d{1,2}(?:\s*,\s*dan\s*\d{1,2})?)?)');
  final monthRegex = RegExp(r'^(Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember|Jan|Feb|Mar|Apr|Jun|Jul|Agu|Sep|Okt|Nov|Des)[a-z]*(\s*[-/]\s*(Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember|Jan|Feb|Mar|Apr|Jun|Jul|Agu|Sep|Okt|Nov|Des)[a-z]*)?', caseSensitive: false);
  final yearRegex = RegExp(r'^(20\d{2})');

  for (var text in texts) {
    print('Testing: "$text"');
    final match = dateRegex.firstMatch(text);
    if (match != null) {
      final tanggal = match.group(1)!.trim();
      print('  Tanggal: $tanggal');
      String sisaText = text.substring(match.end).trim();
      
      final mMatch = monthRegex.firstMatch(sisaText);
      if (mMatch != null) {
        print('  Bulan: ${mMatch.group(0)}');
        sisaText = sisaText.substring(mMatch.end).trim();
      }
      
      final yMatch = yearRegex.firstMatch(sisaText);
      if (yMatch != null) {
        print('  Tahun: ${yMatch.group(1)}');
        sisaText = sisaText.substring(yMatch.end).trim();
      }
      
      print('  Sisa: $sisaText');
    } else {
      print('  No date match at start.');
    }
  }
}
