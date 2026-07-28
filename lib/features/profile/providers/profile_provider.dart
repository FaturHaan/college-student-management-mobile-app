import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:student_management_app/features/profile/data/models/profile_model.dart';

// Box name constant
const String profileBoxName = 'profileBox';
const String profileKey = 'currentProfile';

/// StateNotifier untuk mengelola state profil mahasiswa
class ProfileNotifier extends StateNotifier<ProfileModel?> {
  ProfileNotifier() : super(null) {
    _loadProfile();
  }

  /// Memuat profil dari Hive saat pertama kali
  void _loadProfile() {
    final box = Hive.box<ProfileModel>(profileBoxName);
    state = box.get(profileKey);
  }

  /// Menyimpan profil baru (Onboarding)
  Future<void> saveProfile(ProfileModel profile) async {
    final box = Hive.box<ProfileModel>(profileBoxName);
    await box.put(profileKey, profile);
    state = profile;
  }

  /// Memperbarui profil yang sudah ada
  Future<void> updateProfile({
    String? name,
    String? university,
    String? major,
    int? activeSemester,
    double? targetIpk,
  }) async {
    if (state == null) return;

    final updated = state!.copyWith(
      name: name,
      university: university,
      major: major,
      activeSemester: activeSemester,
      targetIpk: targetIpk,
    );

    final box = Hive.box<ProfileModel>(profileBoxName);
    await box.put(profileKey, updated);
    state = updated;
  }

  /// Mengecek apakah profil sudah ada
  bool get hasProfile => state != null;
}

/// Provider utama untuk profil mahasiswa
final profileProvider =
    StateNotifierProvider<ProfileNotifier, ProfileModel?>((ref) {
  return ProfileNotifier();
});
