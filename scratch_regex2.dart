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
    "11	Juli	2026	Akhir Perkuliahan Semester Genap",
    "20-22 Agustus 2026 Kegiatan B",
    "2, 3, dan 4 Mei Kegiatan C",
    "1 s/d 5 Juni Kegiatan D"
  ];

  final dateRegex = RegExp(r'\b(\d{1,2}(?:\s*(?:-|s\.?/?d\.?)\s*\d{1,2}|\s*(?:,|dan)\s*\d{1,2})*)\b');
  final monthRegex = RegExp(r'\b(Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember|Jan|Feb|Mar|Apr|Jun|Jul|Agu|Sep|Okt|Nov|Des)(?:\s*[-/]\s*(Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember|Jan|Feb|Mar|Apr|Jun|Jul|Agu|Sep|Okt|Nov|Des))?\b', caseSensitive: false);
  final yearRegex = RegExp(r'\b(20\d{2})\b');

  for (var text in texts) {
    print('Testing: "$text"');
    
    // Temukan bulan dulu
    final mMatch = monthRegex.firstMatch(text);
    // Temukan tahun
    final yMatch = yearRegex.firstMatch(text);
    
    // Temukan tanggal (harus sebelum bulan, atau di awal)
    final dMatches = dateRegex.allMatches(text);
    RegExpMatch? validDateMatch;
    
    for (var match in dMatches) {
       // Abaikan tahun yang terdeteksi sebagai tanggal (seperti "20" dari "2026")
       if (yMatch != null && match.start == yMatch.start) continue;
       
       // Kita ambil match tanggal pertama yang valid
       validDateMatch = match;
       break;
    }

    if (validDateMatch != null) {
      final tanggal = validDateMatch.group(1)!.trim();
      String sisaText = text;
      
      // Hapus tanggal dari string
      sisaText = sisaText.replaceRange(validDateMatch.start, validDateMatch.end, ' ');
      
      String currentBulan = '-';
      if (mMatch != null) {
        currentBulan = mMatch.group(1)!;
        sisaText = sisaText.replaceFirst(mMatch.group(0)!, ' ');
      }
      
      String currentTahun = '-';
      if (yMatch != null) {
        currentTahun = yMatch.group(1)!;
        sisaText = sisaText.replaceFirst(yMatch.group(0)!, ' ');
      }
      
      // Bersihkan sisaText
      sisaText = sisaText.replaceAll(RegExp(r'\s+'), ' ').trim();
      sisaText = sisaText.replaceAll(RegExp(r'^[-,\s]+'), '').trim();
      
      print('  Tanggal: $tanggal');
      print('  Bulan: $currentBulan');
      print('  Tahun: $currentTahun');
      print('  Sisa: $sisaText');
    } else {
      print('  No date match.');
    }
  }
}
