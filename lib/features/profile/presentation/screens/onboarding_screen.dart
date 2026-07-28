import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_app/core/theme/app_colors.dart';
import 'package:student_management_app/features/profile/data/models/profile_model.dart';
import 'package:student_management_app/features/profile/providers/profile_provider.dart';
import 'package:student_management_app/features/home/presentation/screens/home_screen.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _universityController = TextEditingController();
  final _majorController = TextEditingController();
  final _semesterController = TextEditingController(text: '1');
  final _targetIpkController = TextEditingController(text: '3.50');

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nameController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _semesterController.dispose();
    _targetIpkController.dispose();
    super.dispose();
  }

  void _nextStep() {
    if (_currentStep < 2) {
      setState(() => _currentStep++);
      _animationController.reset();
      _animationController.forward();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
      _animationController.reset();
      _animationController.forward();
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = ProfileModel(
      name: _nameController.text.trim(),
      university: _universityController.text.trim(),
      major: _majorController.text.trim(),
      activeSemester: int.tryParse(_semesterController.text.trim()) ?? 1,
      targetIpk: double.tryParse(_targetIpkController.text.trim()) ?? 3.50,
    );

    await ref.read(profileProvider.notifier).saveProfile(profile);

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Header
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Progress indicator
                      Row(
                        children: List.generate(3, (index) {
                          return Expanded(
                            child: Container(
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              height: 4,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                color: index <= _currentStep
                                    ? Colors.white
                                    : Colors.white.withAlpha(77),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        _getStepTitle(),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStepSubtitle(),
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withAlpha(179),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),

                // Content
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 24),
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(26),
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(
                            color: Colors.white.withAlpha(51),
                            width: 1,
                          ),
                        ),
                        child: SingleChildScrollView(
                          child: _buildStepContent(),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Navigation buttons
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Row(
                    children: [
                      if (_currentStep > 0)
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _previousStep,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Colors.white70),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: const Text(
                              'Kembali',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      if (_currentStep > 0) const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: ElevatedButton(
                          onPressed:
                              _currentStep == 2 ? _saveProfile : _nextStep,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.white,
                            foregroundColor: AppColors.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            _currentStep == 2 ? 'Mulai Sekarang 🚀' : 'Lanjut',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 0:
        return 'Selamat Datang! 👋';
      case 1:
        return 'Kampus Kamu 🏫';
      case 2:
        return 'Target & Motivasi 🎯';
      default:
        return '';
    }
  }

  String _getStepSubtitle() {
    switch (_currentStep) {
      case 0:
        return 'Kenalan dulu yuk, siapa nama kamu?';
      case 1:
        return 'Ceritakan tentang kampus dan jurusan kamu';
      case 2:
        return 'Tetapkan tujuanmu agar selalu termotivasi';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1();
      case 1:
        return _buildStep2();
      case 2:
        return _buildStep3();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        const Icon(Icons.person_outline_rounded,
            size: 80, color: Colors.white70),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _nameController,
          label: 'Nama Lengkap',
          icon: Icons.badge_outlined,
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        const Icon(Icons.school_outlined, size: 80, color: Colors.white70),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _universityController,
          label: 'Nama Universitas',
          icon: Icons.account_balance_outlined,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Universitas wajib diisi'
              : null,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _majorController,
          label: 'Program Studi / Jurusan',
          icon: Icons.menu_book_outlined,
          validator: (v) => (v == null || v.trim().isEmpty)
              ? 'Program studi wajib diisi'
              : null,
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        const Icon(Icons.emoji_events_outlined,
            size: 80, color: Colors.white70),
        const SizedBox(height: 24),
        _buildTextField(
          controller: _semesterController,
          label: 'Semester Aktif',
          icon: Icons.calendar_today_outlined,
          keyboardType: TextInputType.number,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Semester wajib diisi';
            final n = int.tryParse(v.trim());
            if (n == null || n < 1 || n > 14) {
              return 'Masukkan semester yang valid (1-14)';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        _buildTextField(
          controller: _targetIpkController,
          label: 'Target IPK',
          icon: Icons.star_outline_rounded,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Target IPK wajib diisi';
            final n = double.tryParse(v.trim());
            if (n == null || n < 0 || n > 4.0) {
              return 'Masukkan IPK yang valid (0.00 - 4.00)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 16),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withAlpha(179)),
        prefixIcon: Icon(icon, color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: Colors.white.withAlpha(77)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.white, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Colors.redAccent, width: 2),
        ),
        filled: true,
        fillColor: Colors.white.withAlpha(13),
        errorStyle: const TextStyle(color: Colors.orangeAccent),
      ),
    );
  }
}
