import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:student_management_app/core/theme/app_theme.dart';
import 'package:student_management_app/data/database/hive_setup.dart';
import 'package:student_management_app/core/services/notification_service.dart';
import 'package:student_management_app/core/providers/theme_provider.dart';
import 'package:student_management_app/features/profile/providers/profile_provider.dart';
import 'package:student_management_app/features/profile/presentation/screens/onboarding_screen.dart';
import 'package:student_management_app/features/onboarding/presentation/screens/tutorial_screen.dart';
import 'package:student_management_app/features/home/presentation/screens/home_screen.dart';
import 'package:hive/hive.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Database Hive
  await HiveSetup.init();

  // Inisialisasi Notification Service
  await NotificationService().init();
  await NotificationService().requestPermissions();

  runApp(
    const ProviderScope(
      child: StudentManagementApp(),
    ),
  );
}

class StudentManagementApp extends ConsumerWidget {
  const StudentManagementApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Cek apakah profil sudah ada di database
    final profile = ref.watch(profileProvider);
    final isDarkMode = ref.watch(themeProvider);

    // Cek status tutorial
    final box = Hive.box('settingsBox');
    final bool hasSeenTutorial = box.get('hasSeenTutorial', defaultValue: false);

    Widget homeWidget;
    if (!hasSeenTutorial) {
      homeWidget = const TutorialScreen();
    } else if (profile == null) {
      homeWidget = const OnboardingScreen();
    } else {
      homeWidget = const HomeScreen();
    }

    return MaterialApp(
      title: 'Collagement',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: homeWidget,
    );
  }
}
