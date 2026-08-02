import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:student_management_app/core/theme/app_colors.dart';
import 'package:student_management_app/features/profile/presentation/screens/onboarding_screen.dart';
import 'package:student_management_app/features/home/presentation/screens/home_screen.dart';
import 'package:student_management_app/features/profile/providers/profile_provider.dart';

class TutorialScreen extends ConsumerStatefulWidget {
  const TutorialScreen({super.key});

  @override
  ConsumerState<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends ConsumerState<TutorialScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _tutorialData = [
    {
      'title': 'Manajemen Jadwal & Tugas',
      'description': 'Lacak jadwal kuliah harianmu dan pastikan tidak ada tugas yang terlewat dengan fitur pengingat pintar.',
      'icon': Icons.calendar_today_rounded,
      'color': const Color(0xFF6200EE),
    },
    {
      'title': 'Pencatatan Keuangan',
      'description': 'Atur pengeluaran dan pemasukan bulananmu, pastikan keuangan tetap stabil sebagai mahasiswa mandiri.',
      'icon': Icons.account_balance_wallet_rounded,
      'color': const Color(0xFFFF9800),
    },
    {
      'title': 'Kalkulator & Target IPK',
      'description': 'Simpan nilai mata kuliahmu dan lihat proyeksi target IPK yang harus dicapai pada semester-semester berikutnya.',
      'icon': Icons.school_rounded,
      'color': const Color(0xFF03DAC6),
    }
  ];

  Future<void> _finishTutorial() async {
    // Simpan status bahwa tutorial sudah dilihat
    final box = Hive.box('settingsBox');
    await box.put('hasSeenTutorial', true);

    // Cek profil
    final profile = ref.read(profileProvider);
    if (!mounted) return;

    if (profile == null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            onPageChanged: (int page) {
              setState(() {
                _currentPage = page;
              });
            },
            itemCount: _tutorialData.length,
            itemBuilder: (context, index) {
              return _buildPageContent(_tutorialData[index]);
            },
          ),
          
          // Indikator Titik (Dots) dan Tombol Navigasi
          Positioned(
            bottom: 40,
            left: 24,
            right: 24,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Dots Indicator
                Row(
                  children: List.generate(
                    _tutorialData.length,
                    (index) => AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      margin: const EdgeInsets.only(right: 8),
                      height: 10,
                      width: _currentPage == index ? 24 : 10,
                      decoration: BoxDecoration(
                        color: _currentPage == index 
                          ? _tutorialData[_currentPage]['color'] 
                          : Colors.grey.shade400,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                ),
                
                // Button Navigasi
                ElevatedButton(
                  onPressed: () {
                    if (_currentPage == _tutorialData.length - 1) {
                      _finishTutorial();
                    } else {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 500),
                        curve: Curves.ease,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _tutorialData[_currentPage]['color'],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                    elevation: 5,
                    shadowColor: _tutorialData[_currentPage]['color'].withAlpha(102),
                  ),
                  child: Text(
                    _currentPage == _tutorialData.length - 1 ? 'Mulai' : 'Lanjut',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(Map<String, dynamic> data) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon Box dengan Gradient dan Shadow
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: (data['color'] as Color).withAlpha(51),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Icon(
              data['icon'],
              size: 100,
              color: data['color'],
            ),
          ),
          const SizedBox(height: 60),
          
          // Teks Judul
          Text(
            data['title'],
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 20),
          
          // Deskripsi
          Text(
            data['description'],
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
