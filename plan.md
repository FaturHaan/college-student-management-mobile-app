# Rencana Pengembangan Aplikasi Manajemen Perkuliahan (College Student Management Mobile App)

## 1. Rencana Implementasi: Dashboard Hidup + Kalkulator & Proyeksi IPK

### Konteks Teknis
- Box Hive & typeId terpakai: Profile=0, Schedule=1, Task=3, Transaction=4 → **typeId 2 bebas** untuk model baru.
- Semua data sudah tersedia via provider: `scheduleProvider`, `taskProvider`, `financeProvider`, `profileProvider`.
- Home (`lib/features/home/presentation/screens/home_screen.dart`) masih memakai stat card placeholder ("Buka").

### 1.1. Dashboard Hidup

**Modifikasi:** `lib/features/home/presentation/screens/home_screen.dart`

Ganti 3 kartu placeholder + tambah 1 kartu dengan data real:

| Kartu | Sumber Data | Isi |
|-------|-------------|-----|
| **Kelas Berikutnya** | `scheduleProvider` | Parse `hari` + `waktu` (contoh "07:00 - 07:50") → cari kelas hari ini/berikutnya; tampilkan MK + ruangan + jam. Fallback "Tidak ada kelas hari ini". |
| **Tugas Terdekat** | `taskProvider` | Tugas dengan deadline terdekat (status ≠ Selesai) + hitung mundur "H-2 · 5 jam". Tap → TasksScreen. |
| **Sisa Budget** | `financeProvider` | `budgetLimit - totalExpenseThisMonth`, warna peringatan jika sisa < 30%. Tap → FinanceScreen. |
| **Target IPK** | `profileProvider` + `ipkProvider` (baru) | Ring progress IPK saat ini vs `targetIpk`. Tap → IPKScreen. |

**Detail teknis:**
- Tambah `Timer.periodic` (interval 1 menit) di `initState` untuk memperbarui hitung mundur & kelas berikutnya.
- Buat helper parsing hari→weekday dan parsing jam dari string `waktu`.

### 1.2. Kalkulator & Proyeksi IPK

**Modul baru:** `lib/features/ipk/`

**1. Model — `data/models/grade_model.dart`**
- `@HiveType(typeId: 2)` — `GradeModel` dengan field: `id`, `namaMk`, `kodeMk` (opsional, untuk relasi ke jadwal), `sks` (int), `grade` (String), `semester` (int).
- Bobot nilai (skala politeknik): A=4.0, AB=3.5, B=3.0, BC=2.5, C=2.0, D=1.0, E=0.

**2. Provider — `providers/grade_provider.dart`**
- `StateNotifier<List<GradeModel>>` + CRUD (add/remove/update).
- Getter: `ipkPerSemester`, `currentIpk` (Σ bobot×SKS / Σ SKS), `totalSks`.

**3. Screen — `presentation/screens/ipk_screen.dart`**
- List semester + kartu IPK per semester & IPK kumulatif.
- Dialog tambah nilai: Nama MK (dropdown dari jadwal jika tersedia), SKS, grade (A-E), semester.
- **Proyeksi:** "Untuk capai target `targetIpk`, dibutuhkan rata-rata **X** di sisa semester."

**4. Integrasi — modifikasi file existing:**
- `lib/data/database/hive_setup.dart` → register adapter `GradeModelAdapter` + buka box `gradesBox`.
- Jalankan `dart run build_runner build --delete-conflicting-outputs` untuk generate `grade_model.g.dart`.
- Dashboard card "Target IPK" menautkan ke `IPKScreen`.

### 1.3. Alur Kerja
1. Buat model + provider IPK → generate adapter → daftarkan di `hive_setup.dart`.
2. Buat `IPKScreen`.
3. Rombak `home_screen.dart` → dashboard hidup (4 kartu data real + link ke `IPKScreen`).
4. Verifikasi: `flutter analyze` + `flutter test`.
