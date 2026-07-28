import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:student_management_app/features/schedule/data/models/schedule_model.dart';
import 'package:student_management_app/core/services/notification_service.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:uuid/uuid.dart';

const String schedulesBoxName = 'schedulesBox';

class ScheduleNotifier extends StateNotifier<List<ScheduleModel>> {
  ScheduleNotifier() : super([]) {
    _loadSchedules();
  }

  void _loadSchedules() {
    final box = Hive.box<ScheduleModel>(schedulesBoxName);
    state = box.values.toList();
  }

  Future<void> addSchedule(ScheduleModel schedule) async {
    final box = Hive.box<ScheduleModel>(schedulesBoxName);
    await box.put(schedule.id, schedule);
    await NotificationService().scheduleClassReminder(schedule);
    state = [...state, schedule];
  }

  Future<void> removeSchedule(String id) async {
    final box = Hive.box<ScheduleModel>(schedulesBoxName);
    await box.delete(id);
    await NotificationService().cancelClassReminder(id);
    state = state.where((s) => s.id != id).toList();
  }

  Future<void> clearAllSchedules() async {
    final box = Hive.box<ScheduleModel>(schedulesBoxName);
    await box.clear();
    state = [];
  }

  /// Daftar kelas unik yang tersedia
  List<String> get availableClasses {
    final classes = state.map((s) => s.kelas).toSet().toList();
    classes.sort();
    return classes;
  }

  /// Mengekstrak jadwal dari file PDF
  /// Format teks dari PDF: semua kolom menyatu tanpa spasi, contoh:
  /// SENIN107.00-07.5025TI1106Proyek 1 : Pengembangan ...PRKO074NMuhammad Rizqi SD106-Lab. SDB1A-D4
  Future<bool> extractScheduleFromPdf(String filePath) async {
    try {
      final file = File(filePath);
      final bytes = await file.readAsBytes();
      
      final PdfDocument document = PdfDocument(inputBytes: bytes);
      String text = PdfTextExtractor(document).extractText();
      document.dispose();

      debugPrint('=== RAW PDF TEXT (first 500 chars) ===');
      debugPrint(text.substring(0, text.length > 500 ? 500 : text.length));
      debugPrint('=== END ===');

      final List<ScheduleModel> extractedSchedules = [];
      final lines = text.split('\n').map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
      
      const uuid = Uuid();
      final hariList = ['SENIN', 'SELASA', 'RABU', 'KAMIS', 'JUMAT', 'SABTU', 'MINGGU'];

      // RegExp utama: menangkap HARI + JAMKE + WAKTU + KODEMK + NAMAMK + TE/PR + KODEDOSEN + NAMADOSEN + RUANGAN + KELAS
      // Format: SENIN107.00-07.5025TI1106NamaMKTE/PRKO074NNama DosenD106-Lab. SDB1A-D4
      //
      // Breakdown:
      // (SENIN|SELASA|...)  -> hari
      // (\d{1,2})           -> jam ke
      // (\d{2}\.\d{2}-\d{2}\.\d{2})  -> waktu
      // (25\w{2}\d{4})      -> kode MK (format: 25XX9999)
      // (.+?)               -> nama MK (lazy, sampai TE/PR)
      // (TE|PR)             -> tipe
      // ([A-Z]{2}\d{3}[A-Z](?:;[A-Z]{2}\d{3}[A-Z])*)  -> kode dosen (satu atau lebih, dipisah ;)
      // (.+?)               -> nama dosen (lazy, sampai pola ruangan)
      // ([A-Z]\d{3}-[^\d]+?)  -> ruangan (misal D106-Lab. SDB)
      // (\d[A-Z]-D\d)       -> kelas (misal 1A-D4)

      final fullLineRegex = RegExp(
        r'^(SENIN|SELASA|RABU|KAMIS|JUMAT|SABTU|MINGGU)'  // 1: hari
        r'(\d{1,2})'                                       // 2: jam ke
        r'(\d{2}\.\d{2}-\d{2}\.\d{2})'                    // 3: waktu
        r'(\d{2}[A-Z]{2}\d{4})'                           // 4: kode MK
        r'(.+?)'                                           // 5: nama MK
        r'(TE|PR)'                                         // 6: tipe
        r'([A-Z]{2}\d{3}[A-Z](?:;[A-Z]{2}\d{3}[A-Z])*)'  // 7: kode dosen
        r'(.+?)'                                           // 8: nama dosen
        r'([A-Z]\d{2,3}-[A-Za-z. ]+?)'                    // 9: ruangan
        r'(\d[A-Z]-D\d)$'                                  // 10: kelas
      );

      // Regex untuk baris tanpa MK (slot kosong): SENIN1015.50-16.401A-D4
      final emptySlotRegex = RegExp(
        r'^(SENIN|SELASA|RABU|KAMIS|JUMAT|SABTU|MINGGU)'
        r'(\d{1,2})'
        r'(\d{2}\.\d{2}-\d{2}\.\d{2})'
        r'(\d[A-Z]-D\d)$'
      );

      // Regex untuk baris terpisah (multi-line):
      // Line 1: SENIN107.00-07.5025TI1106Proyek 1 : ...PRKO065N;KO001N;KO066N
      // Line 2: Aprianti Nanda S;Ade Chandra Nugraha;Ardhian Ekawijana
      // Line 3: D102-Lab. MT1B-D4
      final partialLineRegex = RegExp(
        r'^(SENIN|SELASA|RABU|KAMIS|JUMAT|SABTU|MINGGU)'
        r'(\d{1,2})'
        r'(\d{2}\.\d{2}-\d{2}\.\d{2})'
        r'(\d{2}[A-Z]{2}\d{4})'
        r'(.+?)'
        r'(TE|PR)'
        r'([A-Z]{2}\d{3}[A-Z](?:;[A-Z]{2}\d{3}[A-Z])*)$'
      );

      // Regex untuk baris ruangan + kelas
      final roomClassRegex = RegExp(r'^([A-Z]\d{2,3}-[A-Za-z. ]+?)(\d[A-Z]-D\d)$');

      int i = 0;
      while (i < lines.length) {
        final line = lines[i];

        // Skip headers, istirahat, dll
        if (line.toUpperCase().contains('ISTIRAHAT') ||
            line.toUpperCase().contains('KODE MK') ||
            line.toUpperCase().contains('NAMA MK') ||
            line.toUpperCase().contains('FORMULIR') ||
            line.toUpperCase().contains('BERLAKU DARI') ||
            line.toUpperCase().contains('JURUSAN') ||
            line.toUpperCase().contains('POLITEKNIK') ||
            line.toUpperCase().contains('PROGRAM STUDI') ||
            line.toUpperCase().contains('KELAS') && line.length < 10 ||
            line.toUpperCase().contains('KURIKULUM') ||
            line.toUpperCase().contains('SEMESTER') && line.length < 15 ||
            line.toUpperCase().contains('TAHUN AKADEMIK') ||
            line.toUpperCase().contains('VERSI') ||
            line == '0' ||
            line.startsWith(':')) {
          i++;
          continue;
        }

        // Cek apakah baris header kolom
        bool isHeader = false;
        for (var h in ['HARI', 'JAM', 'KE', 'WAKTU', 'TE/P', 'R', 'NAMA DOSEN', 'RuanganKELAS', 'KODE DOSEN']) {
          if (line == h) { isHeader = true; break; }
        }
        if (isHeader) { i++; continue; }

        // 1. Coba full line match
        final fullMatch = fullLineRegex.firstMatch(line);
        if (fullMatch != null) {
          extractedSchedules.add(_createSchedule(uuid, fullMatch));
          i++;
          continue;
        }

        // 2. Coba empty slot match (skip, tidak ada MK)
        final emptyMatch = emptySlotRegex.firstMatch(line);
        if (emptyMatch != null) {
          i++;
          continue;
        }

        // 3. Coba partial line match (multi-line format)
        final partialMatch = partialLineRegex.firstMatch(line);
        if (partialMatch != null) {
          String hari = partialMatch.group(1)!;
          String jamKe = partialMatch.group(2)!;
          String waktu = partialMatch.group(3)!.replaceAll('.', ':');
          String kodeMk = partialMatch.group(4)!;
          String namaMk = partialMatch.group(5)!;
          String tePr = partialMatch.group(6)!;
          String kodeDosen = partialMatch.group(7)!;
          String namaDosen = '-';
          String ruangan = '-';
          String kelas = '-';

          // Baris berikutnya harusnya nama dosen
          if (i + 1 < lines.length) {
            final nextLine = lines[i + 1];
            // Cek apakah baris berikutnya bukan baris jadwal baru
            bool isScheduleLine = false;
            for (var h in hariList) {
              if (nextLine.startsWith(h)) { isScheduleLine = true; break; }
            }
            if (!isScheduleLine && !nextLine.toUpperCase().contains('ISTIRAHAT')) {
              namaDosen = nextLine.replaceAll(';', '; ');
              
              // Baris setelahnya harusnya ruangan+kelas
              if (i + 2 < lines.length) {
                final roomLine = lines[i + 2];
                final roomMatch = roomClassRegex.firstMatch(roomLine);
                if (roomMatch != null) {
                  ruangan = roomMatch.group(1)!;
                  kelas = roomMatch.group(2)!;
                  i += 3;
                } else {
                  i += 2;
                }
              } else {
                i += 2;
              }
            } else {
              i++;
            }
          } else {
            i++;
          }

          extractedSchedules.add(
            ScheduleModel(
              id: uuid.v4(),
              kodeMk: kodeMk,
              namaMk: namaMk,
              tePr: tePr,
              kodeDosen: kodeDosen,
              namaDosen: namaDosen,
              ruangan: ruangan,
              kelas: kelas,
              hari: _capitalizeHari(hari),
              jamKe: jamKe,
              waktu: waktu,
            ),
          );
          continue;
        }

        // Baris tidak cocok, skip
        i++;
      }

      // Deduplicate: Gabungkan jam yang berurutan untuk MK yang sama
      final Map<String, ScheduleModel> merged = {};
      for (var s in extractedSchedules) {
        final key = '${s.hari}_${s.kodeMk}_${s.kelas}_${s.tePr}';
        if (merged.containsKey(key)) {
          // Gabungkan waktu
          final existing = merged[key]!;
          final existingEnd = existing.waktu.split('-').last.trim();
          final newEnd = s.waktu.split('-').last.trim();
          // Ambil waktu akhir yang paling besar
          final mergedWaktu = '${existing.waktu.split('-').first.trim()} - $newEnd';
          // Gabungkan jam ke
          final mergedJamKe = '${existing.jamKe}-${s.jamKe}';
          merged[key] = ScheduleModel(
            id: existing.id,
            kodeMk: existing.kodeMk,
            namaMk: existing.namaMk,
            tePr: existing.tePr,
            kodeDosen: existing.kodeDosen,
            namaDosen: existing.namaDosen,
            ruangan: existing.ruangan,
            kelas: existing.kelas,
            hari: existing.hari,
            jamKe: mergedJamKe,
            waktu: mergedWaktu,
          );
        } else {
          merged[key] = s;
        }
      }

      final finalSchedules = merged.values.toList();

      // Jika berhasil mengekstrak, timpa jadwal yang lama
      if (finalSchedules.isNotEmpty) {
        await clearAllSchedules();
        final box = Hive.box<ScheduleModel>(schedulesBoxName);
        
        for (var schedule in finalSchedules) {
          await box.put(schedule.id, schedule);
          await NotificationService().scheduleClassReminder(schedule);
        }
        
        state = finalSchedules;
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error extracting PDF: $e');
      return false;
    }
  }

  ScheduleModel _createSchedule(Uuid uuid, RegExpMatch match) {
    String namaDosen = match.group(8)?.trim() ?? '-';
    namaDosen = namaDosen.replaceAll(';', '; ');
    
    return ScheduleModel(
      id: uuid.v4(),
      kodeMk: match.group(4)!,
      namaMk: match.group(5)!,
      tePr: match.group(6)!,
      kodeDosen: match.group(7)!,
      namaDosen: namaDosen,
      ruangan: match.group(9)!,
      kelas: match.group(10)!,
      hari: _capitalizeHari(match.group(1)!),
      jamKe: match.group(2)!,
      waktu: match.group(3)!.replaceAll('.', ':'),
    );
  }

  String _capitalizeHari(String hari) {
    return hari[0].toUpperCase() + hari.substring(1).toLowerCase();
  }
}

final scheduleProvider = StateNotifierProvider<ScheduleNotifier, List<ScheduleModel>>((ref) {
  return ScheduleNotifier();
});
