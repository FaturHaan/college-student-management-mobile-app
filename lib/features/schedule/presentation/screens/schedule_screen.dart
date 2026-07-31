import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_app/core/theme/app_colors.dart';
import 'package:student_management_app/features/schedule/providers/schedule_provider.dart';
import 'package:student_management_app/features/schedule/providers/schedule_reminder_provider.dart';

class ScheduleScreen extends ConsumerStatefulWidget {
  const ScheduleScreen({super.key});

  @override
  ConsumerState<ScheduleScreen> createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends ConsumerState<ScheduleScreen> {
  bool _isLoadingPdf = false;
  String? _selectedKelas; // Filter kelas
  bool _showOnlyToday = false; // Filter hari ini

  Future<void> _importSchedulePdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() => _isLoadingPdf = true);
      final success = await ref.read(scheduleProvider.notifier).extractScheduleFromPdf(result.files.single.path!);
      setState(() {
        _isLoadingPdf = false;
        _selectedKelas = null; // Reset filter setelah impor baru
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(success ? 'Jadwal berhasil diekstrak! ✅' : 'Gagal membaca PDF. Pastikan format sesuai.'),
            backgroundColor: success ? AppColors.primary : Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jadwal Kuliah'),
      ),
      body: _isLoadingPdf
          ? const Center(child: CircularProgressIndicator())
          : _buildScheduleView(),
      floatingActionButton: FloatingActionButton(
        onPressed: _importSchedulePdf,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.upload_file),
      ),
    );
  }

  Widget _buildScheduleView() {
    final schedules = ref.watch(scheduleProvider);
    final notifier = ref.read(scheduleProvider.notifier);

    if (schedules.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 16),
            Text(
              'Belum ada jadwal',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[500]),
            ),
            const SizedBox(height: 8),
            Text(
              'Tekan tombol + untuk mengimpor dari PDF',
              style: TextStyle(fontSize: 14, color: Colors.grey[400]),
            ),
          ],
        ),
      );
    }

    // Ambil daftar kelas unik
    final availableClasses = notifier.availableClasses;

    // Filter berdasarkan kelas yang dipilih
    final filteredSchedules = _selectedKelas != null
        ? schedules.where((s) => s.kelas == _selectedKelas).toList()
        : schedules;
    
    final hariOrder = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'];
    String todayString = hariOrder[DateTime.now().weekday - 1];

    List<dynamic> finalSchedules = filteredSchedules;
    if (_showOnlyToday) {
      finalSchedules = filteredSchedules.where((s) => s.hari == todayString).toList();
    }
    
    // Kelompokkan berdasarkan Hari
    final grouped = <String, List<dynamic>>{};
    for (var s in finalSchedules) {
      grouped.putIfAbsent(s.hari, () => []).add(s);
    }
    // Sort keys berdasarkan urutan hari
    final sortedKeys = grouped.keys.toList()
      ..sort((a, b) => hariOrder.indexOf(a).compareTo(hariOrder.indexOf(b)));

    return Column(
      children: [
        // Filter Kelas & Hari
        if (availableClasses.length > 1 || schedules.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip('Semua Kelas', _selectedKelas == null, () {
                    setState(() => _selectedKelas = null);
                  }),
                  const SizedBox(width: 8),
                  _buildFilterChip('Hari Ini', _showOnlyToday, () {
                    setState(() => _showOnlyToday = !_showOnlyToday);
                  }),
                  const SizedBox(width: 8),
                  if (availableClasses.length > 1)
                    ...availableClasses.map((kelas) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _buildFilterChip('Kelas $kelas', _selectedKelas == kelas, () {
                        setState(() => _selectedKelas = kelas);
                      }),
                    )),
                ],
              ),
            ),
          ),

        // Daftar Jadwal
        Expanded(
          child: filteredSchedules.isEmpty
            ? Center(
                child: Text(
                  'Tidak ada jadwal untuk kelas ini.',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(bottom: 80),
                itemCount: sortedKeys.length,
                itemBuilder: (context, index) {
                  String hari = sortedKeys[index];
                  var dailySchedules = grouped[hari]!;
                  
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Hari
                      Container(
                        width: double.infinity,
                        margin: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              _getHariColor(hari),
                              _getHariColor(hari).withValues(alpha: 0.7),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.today, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            Text(
                              hari,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${dailySchedules.length} mata kuliah',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.white.withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Cards Jadwal
                      ...dailySchedules.map((s) {
                        final reminderState = ref.watch(scheduleReminderProvider);
                        final hasReminder = reminderState.containsKey(s.id);
                        return Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                          child: Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: InkWell(
                              onTap: () => _showScheduleDetails(context, s),
                              borderRadius: BorderRadius.circular(12),
                              child: Padding(
                                padding: const EdgeInsets.all(14),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Nama MK + Badge Kelas + Bell icon
                                    Row(
                                      children: [
                                        Expanded(
                                          child: Text(
                                            s.namaMk,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                        // Ikon pengingat
                                        if (hasReminder)
                                          Padding(
                                            padding: const EdgeInsets.only(right: 6),
                                            child: Icon(
                                              Icons.notifications_active,
                                              size: 18,
                                              color: Colors.amber[700],
                                            ),
                                          ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: AppColors.primary.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            s.kelas,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 6),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: s.tePr.toUpperCase() == 'PR'
                                                ? Colors.orange.withValues(alpha: 0.1)
                                                : Colors.blue.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(8),
                                          ),
                                          child: Text(
                                            s.tePr,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: s.tePr.toUpperCase() == 'PR' ? Colors.orange : Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    // Detail info
                                    Row(
                                      children: [
                                        Icon(Icons.access_time, size: 15, color: Colors.grey[500]),
                                        const SizedBox(width: 6),
                                        Text(
                                          s.waktu.isNotEmpty ? s.waktu : '-',
                                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                        ),
                                        const SizedBox(width: 16),
                                        Icon(Icons.room_outlined, size: 15, color: Colors.grey[500]),
                                        const SizedBox(width: 4),
                                        Text(
                                          s.ruangan.isNotEmpty ? s.ruangan : '-',
                                          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 6),
                                    Row(
                                      children: [
                                        Icon(Icons.person_outline, size: 15, color: Colors.grey[500]),
                                        const SizedBox(width: 6),
                                        Expanded(
                                          child: Text(
                                            s.namaDosen.isNotEmpty ? s.namaDosen : '-',
                                            style: TextStyle(fontSize: 13, color: Colors.grey[700]),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  );
                },
              ),
        ),
      ],
    );
  }

  void _showScheduleDetails(BuildContext context, dynamic s) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _ScheduleDetailSheet(schedule: s),
    );
  }


  Widget _buildFilterChip(String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : Colors.grey[200],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[700],
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Color _getHariColor(String hari) {
    switch (hari) {
      case 'Senin': return const Color(0xFF6200EE);
      case 'Selasa': return const Color(0xFF0288D1);
      case 'Rabu': return const Color(0xFF00897B);
      case 'Kamis': return const Color(0xFFE64A19);
      case 'Jumat': return const Color(0xFF7B1FA2);
      case 'Sabtu': return const Color(0xFF455A64);
      case 'Minggu': return const Color(0xFFC62828);
      default: return AppColors.primary;
    }
  }
}

/// Bottom sheet detail jadwal dengan fitur pengingat
class _ScheduleDetailSheet extends ConsumerStatefulWidget {
  final dynamic schedule;
  const _ScheduleDetailSheet({required this.schedule});

  @override
  ConsumerState<_ScheduleDetailSheet> createState() => _ScheduleDetailSheetState();
}

class _ScheduleDetailSheetState extends ConsumerState<_ScheduleDetailSheet> {
  static const List<int> _reminderOptions = [15, 30, 60, 120];

  String _minutesToLabel(int minutes) {
    if (minutes >= 120) return '${minutes ~/ 60} jam';
    if (minutes >= 60) return '1 jam';
    return '$minutes menit';
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.schedule;
    final reminderState = ref.watch(scheduleReminderProvider);
    final reminderNotifier = ref.read(scheduleReminderProvider.notifier);
    final isEnabled = reminderState.containsKey(s.id);
    final currentMinutes = reminderNotifier.getReminderMinutes(s.id);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 50,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Detail Jadwal',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary),
            ),
            const SizedBox(height: 20),
            _buildDetailRow('Hari', s.hari),
            _buildDetailRow('Jam Ke', s.jamKe),
            _buildDetailRow('Waktu', s.waktu),
            _buildDetailRow('Kode MK', s.kodeMk),
            _buildDetailRow('Nama MK', s.namaMk),
            _buildDetailRow('TE/PR', s.tePr),
            _buildDetailRow('Kode Dosen', s.kodeDosen),
            _buildDetailRow('Nama Dosen', s.namaDosen),
            _buildDetailRow('Ruangan', s.ruangan),
            _buildDetailRow('Kelas', s.kelas),
            const SizedBox(height: 16),

            // === Pengaturan Pengingat ===
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isEnabled
                    ? Colors.amber.withValues(alpha: 0.08)
                    : Colors.grey.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isEnabled
                      ? Colors.amber.withValues(alpha: 0.3)
                      : Colors.grey.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isEnabled ? Icons.notifications_active : Icons.notifications_off_outlined,
                        size: 22,
                        color: isEnabled ? Colors.amber[700] : Colors.grey[500],
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Pengingat Kelas',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Switch(
                        value: isEnabled,
                        activeThumbColor: AppColors.primary,
                        onChanged: (val) async {
                          if (val) {
                            await reminderNotifier.setReminder(s, 60);
                          } else {
                            await reminderNotifier.removeReminder(s.id);
                          }
                        },
                      ),
                    ],
                  ),

                  // Pilihan waktu pengingat (hanya tampil jika pengingat aktif)
                  if (isEnabled) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Ingatkan sebelum:',
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _reminderOptions.map((minutes) {
                        final isSelected = currentMinutes == minutes;
                        return GestureDetector(
                          onTap: () async {
                            await reminderNotifier.setReminder(s, minutes);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                            decoration: BoxDecoration(
                              color: isSelected ? AppColors.primary : Colors.grey[200],
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              _minutesToLabel(minutes),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                color: isSelected ? Colors.white : Colors.grey[700],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text('Tutup', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500),
            ),
          ),
          const Text(': ', style: TextStyle(fontWeight: FontWeight.bold)),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
