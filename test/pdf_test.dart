import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

void main() {
  test('Test new PDF regex parser', () async {
    final file = File('Jadwal-semester-2.pdf');
    final bytes = await file.readAsBytes();
    
    final PdfDocument document = PdfDocument(inputBytes: bytes);
    String text = PdfTextExtractor(document).extractText();
    document.dispose();

    final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
    final hariList = ['SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'MINGGU'];

    final fullLineRegex = RegExp(
      r'^(SENIN|SELASA|RABU|KAMIS|JUMAT|SABTU|MINGGU)'
      r'(\d{1,2})'
      r'(\d{2}\.\d{2}-\d{2}\.\d{2})'
      r'(\d{2}[A-Z]{2}\d{4})'
      r'(.+?)'
      r'(TE|PR)'
      r'([A-Z]{2}\d{3}[A-Z](?:;[A-Z]{2}\d{3}[A-Z])*)'
      r'(.+?)'
      r'([A-Z]\d{2,3}-[A-Za-z. ]+?)'
      r'(\d[A-Z]-D\d)$'
    );

    final emptySlotRegex = RegExp(
      r'^(SENIN|SELASA|RABU|KAMIS|JUMAT|SABTU|MINGGU)'
      r'(\d{1,2})'
      r'(\d{2}\.\d{2}-\d{2}\.\d{2})'
      r'(\d[A-Z]-D\d)$'
    );

    final partialLineRegex = RegExp(
      r'^(SENIN|SELASA|RABU|KAMIS|JUMAT|SABTU|MINGGU)'
      r'(\d{1,2})'
      r'(\d{2}\.\d{2}-\d{2}\.\d{2})'
      r'(\d{2}[A-Z]{2}\d{4})'
      r'(.+?)'
      r'(TE|PR)'
      r'([A-Z]{2}\d{3}[A-Z](?:;[A-Z]{2}\d{3}[A-Z])*)$'
    );

    // Baris istirahat tanpa MK: SENIN09.30-09.50
    final breakRegex = RegExp(
      r'^(SENIN|SELASA|RABU|KAMIS|JUMAT|SABTU|MINGGU)'
      r'(\d{2}\.\d{2}-\d{2}\.\d{2})$'
    );

    int fullMatches = 0;
    int emptyMatches = 0;
    int partialMatches = 0;
    int breakMatches = 0;
    int skipped = 0;
    int unmatched = 0;

    for (var line in lines) {
      if (line.toUpperCase().contains('ISTIRAHAT') ||
          line.toUpperCase().contains('KODE MK') ||
          line.toUpperCase().contains('NAMA MK') ||
          line.toUpperCase().contains('FORMULIR') ||
          line.toUpperCase().contains('BERLAKU DARI') ||
          line.toUpperCase().contains('JURUSAN') ||
          line.toUpperCase().contains('POLITEKNIK') ||
          line.toUpperCase().contains('PROGRAM STUDI') ||
          line.toUpperCase().contains('KURIKULUM') ||
          line.toUpperCase().contains('TAHUN AKADEMIK') ||
          line.toUpperCase().contains('VERSI') ||
          line == '0' ||
          line.startsWith(':') ||
          line.length < 5) {
        skipped++;
        continue;
      }
      
      bool isHeader = false;
      for (var h in ['HARI', 'JAM', 'KE', 'WAKTU', 'TE/P', 'R', 'NAMA DOSEN', 'RuanganKELAS', 'KODE DOSEN', 'KODE MKNAMA MK']) {
        if (line == h) { isHeader = true; break; }
      }
      if (isHeader) { skipped++; continue; }

      if (fullLineRegex.hasMatch(line)) {
        fullMatches++;
        final m = fullLineRegex.firstMatch(line)!;
        print('FULL: ${m.group(1)} Jam${m.group(2)} ${m.group(3)} | ${m.group(4)} ${m.group(5)} | ${m.group(6)} | Dosen: ${m.group(8)} | Room: ${m.group(9)} | Class: ${m.group(10)}');
      } else if (emptySlotRegex.hasMatch(line)) {
        emptyMatches++;
      } else if (partialLineRegex.hasMatch(line)) {
        partialMatches++;
        final m = partialLineRegex.firstMatch(line)!;
        print('PARTIAL: ${m.group(1)} Jam${m.group(2)} ${m.group(3)} | ${m.group(4)} ${m.group(5)} | ${m.group(6)} | DosenCode: ${m.group(7)}');
      } else if (breakRegex.hasMatch(line)) {
        breakMatches++;
      } else {
        // Could be a dosen name line or room line from multi-line format
        // Just count and print
        unmatched++;
        if (unmatched <= 20) print('UNMATCHED: |$line|');
      }
    }

    print('\n=== SUMMARY ===');
    print('Full matches (single-line with data): $fullMatches');
    print('Empty slot matches (no MK): $emptyMatches');
    print('Partial matches (multi-line start): $partialMatches');
    print('Break matches: $breakMatches');
    print('Skipped (headers/istirahat/etc): $skipped');
    print('Unmatched: $unmatched');
    print('Total schedule entries: ${fullMatches + partialMatches}');

    expect(fullMatches + partialMatches > 0, true, reason: 'Should match at least some schedule entries');
  });
}
