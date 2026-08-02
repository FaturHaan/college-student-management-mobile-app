import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_app/features/ipk/data/models/grade_model.dart';
import 'package:student_management_app/features/ipk/providers/grade_provider.dart';
import 'package:student_management_app/features/profile/providers/profile_provider.dart';
import 'package:student_management_app/core/theme/app_colors.dart';
import 'package:student_management_app/core/theme/app_text_styles.dart';

class IpkScreen extends ConsumerWidget {
  const IpkScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final grades = ref.watch(gradeProvider);
    final profile = ref.watch(profileProvider);
    final gradeNotifier = ref.read(gradeProvider.notifier);

    final currentIpk = gradeNotifier.currentIpk;
    final targetIpk = profile?.targetIpk ?? 4.0;
    final activeSemester = profile?.activeSemester ?? 1;
    final totalSemesters = 8; // Assuming standard 8 semesters

    // Kalkulasi proyeksi
    double projectionNeeded = 0.0;
    if (activeSemester <= totalSemesters && activeSemester > 1) {
      int sisaSemester = totalSemesters - activeSemester + 1;
      int passedSemester = activeSemester - 1;
      // Basic projection logic: (Target * Total) = (Current * Passed) + (Needed * Sisa)
      // Actually IPK is weighted by SKS, but we can do a simple average approximation if SKS is unknown.
      double totalTarget = targetIpk * totalSemesters;
      double currentTotal = currentIpk * passedSemester;
      projectionNeeded = (totalTarget - currentTotal) / sisaSemester;
    } else if (activeSemester == 1) {
      projectionNeeded = targetIpk;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Kalkulator IPK', style: AppTextStyles.heading2),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Kartu Ringkasan IPK
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.secondary],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withAlpha(76),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'IPK Kumulatif',
                        style: AppTextStyles.body1.copyWith(color: Colors.white70),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        currentIpk.toStringAsFixed(2),
                        style: AppTextStyles.heading1.copyWith(color: Colors.white),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.white.withAlpha(51),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'Target IPK',
                          style: AppTextStyles.body2.copyWith(color: Colors.white),
                        ),
                        Text(
                          targetIpk.toStringAsFixed(2),
                          style: AppTextStyles.heading2.copyWith(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Kartu Proyeksi
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  const Icon(Icons.trending_up, color: AppColors.primary, size: 32),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Proyeksi IPK', style: AppTextStyles.heading2),
                        const SizedBox(height: 4),
                        Text(
                          projectionNeeded > 4.0 
                            ? 'Target tidak realistis, butuh rata-rata ${projectionNeeded.toStringAsFixed(2)} di sisa semester.'
                            : 'Untuk capai target, butuh rata-rata IP ${projectionNeeded.toStringAsFixed(2)} di sisa semester.',
                          style: AppTextStyles.body1.copyWith(color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Daftar Nilai', style: AppTextStyles.heading2),
                ElevatedButton.icon(
                  onPressed: () => _showAddGradeDialog(context, ref),
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // List Nilai
            grades.isEmpty
                ? const Center(
                    child: Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Text('Belum ada data nilai', style: AppTextStyles.body1),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: grades.length,
                    itemBuilder: (context, index) {
                      final grade = grades[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        child: ListTile(
                          title: Text(grade.namaMk, style: AppTextStyles.heading2),
                          subtitle: Text('Semester ${grade.semester} • ${grade.sks} SKS'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: AppColors.surface,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(grade.grade, style: AppTextStyles.heading2.copyWith(color: AppColors.primary)),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                                onPressed: () {
                                  ref.read(gradeProvider.notifier).deleteGrade(grade.id);
                                },
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ],
        ),
      ),
    );
  }

  void _showAddGradeDialog(BuildContext context, WidgetRef ref) {
    final namaMkController = TextEditingController();
    final sksController = TextEditingController();
    final semesterController = TextEditingController(text: ref.read(profileProvider)?.activeSemester.toString() ?? '1');
    String selectedGrade = 'A';
    final List<String> gradeOptions = ['A', 'AB', 'B', 'BC', 'C', 'D', 'E'];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Tambah Nilai'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: namaMkController,
                      decoration: const InputDecoration(labelText: 'Mata Kuliah'),
                    ),
                    TextField(
                      controller: sksController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'SKS'),
                    ),
                    TextField(
                      controller: semesterController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: 'Semester'),
                    ),
                    const SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: selectedGrade,
                      decoration: const InputDecoration(labelText: 'Nilai (Grade)'),
                      items: gradeOptions.map((grade) {
                        return DropdownMenuItem(value: grade, child: Text(grade));
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedGrade = val);
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Batal'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (namaMkController.text.isNotEmpty && sksController.text.isNotEmpty && semesterController.text.isNotEmpty) {
                      final grade = GradeModel(
                        id: '', // Will be generated
                        namaMk: namaMkController.text,
                        sks: int.parse(sksController.text),
                        grade: selectedGrade,
                        semester: int.parse(semesterController.text),
                      );
                      ref.read(gradeProvider.notifier).addGrade(grade);
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Simpan'),
                ),
              ],
            );
          }
        );
      },
    );
  }
}
