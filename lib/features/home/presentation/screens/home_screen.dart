import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_app/core/theme/app_colors.dart';
import 'package:student_management_app/features/profile/providers/profile_provider.dart';
import 'package:student_management_app/features/profile/presentation/screens/profile_screen.dart';
import 'package:student_management_app/features/schedule/presentation/screens/schedule_screen.dart';
import 'package:student_management_app/features/tasks/presentation/screens/tasks_screen.dart';
import 'package:student_management_app/features/finance/presentation/screens/finance_screen.dart';
import 'package:student_management_app/features/settings/presentation/screens/settings_screen.dart';
import 'package:student_management_app/features/tasks/providers/task_provider.dart';
import 'package:student_management_app/core/services/notification_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    NotificationService.onNotificationResponse.addListener(() {
      final data = NotificationService.onNotificationResponse.value;
      if (data != null && data.contains('|')) {
        final parts = data.split('|');
        final actionId = parts[0];
        final taskId = parts[1];
        
        String? newStatus;
        if (actionId == 'action_sedang_dikerjakan') newStatus = 'Sedang Dikerjakan';
        if (actionId == 'action_selesai') newStatus = 'Selesai';
        
        if (newStatus != null) {
          Future.delayed(const Duration(milliseconds: 500), () {
            ref.read(taskProvider.notifier).updateTaskStatus(taskId, newStatus!);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Status tugas diperbarui menjadi $newStatus! ✅'), backgroundColor: Colors.green),
              );
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasksScreen()));
            }
          });
        }
        // Reset
        NotificationService.onNotificationResponse.value = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final greeting = _getGreeting();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Header
          SliverAppBar(
            expandedHeight: 180,
            floating: false,
            pinned: true,
            backgroundColor: AppColors.primary,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6200EE),
                      Color(0xFF3700B3),
                      Color(0xFF1A0056),
                    ],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '$greeting 👋',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withAlpha(179),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile?.name ?? 'Mahasiswa',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Semester ${profile?.activeSemester ?? '-'} · ${profile?.university ?? '-'}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withAlpha(153),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SettingsScreen()),
                  );
                },
                tooltip: 'Pengaturan',
              ),
              IconButton(
                icon: const Icon(Icons.person_outline_rounded),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => const ProfileScreen()),
                  );
                },
                tooltip: 'Profil',
              ),
            ],
          ),

          // Quick stats (placeholder)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ringkasan',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ScheduleScreen()));
                          },
                          child: _buildStatCard(
                            context,
                            icon: Icons.calendar_today_outlined,
                            title: 'Jadwal Kuliah',
                            value: 'Buka',
                            color: const Color(0xFF6200EE),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasksScreen()));
                          },
                          child: _buildStatCard(
                            context,
                            icon: Icons.assignment_outlined,
                            title: 'Tugas Aktif',
                            value: 'Buka',
                            color: const Color(0xFF03DAC6),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: InkWell(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_) => const FinanceScreen()));
                          },
                          child: _buildStatCard(
                            context,
                            icon: Icons.account_balance_wallet_outlined,
                            title: 'Buku Kas',
                            value: 'Buka',
                            color: const Color(0xFFFF9800),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(child: SizedBox()),
                    ],
                  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Selamat Pagi';
    if (hour < 15) return 'Selamat Siang';
    if (hour < 18) return 'Selamat Sore';
    return 'Selamat Malam';
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }
}
