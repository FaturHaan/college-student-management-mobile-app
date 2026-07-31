# Collagement

**Collagement** (College + Management) adalah aplikasi mobile manajemen perkuliahan komprehensif yang membantu mahasiswa mengelola jadwal kuliah, tugas, dan keuangan pribadi dalam satu genggaman.

Dibangun dengan **Flutter** dan **Riverpod**, Collagement mengusung arsitektur *offline-first* dengan database lokal Hive, serta dilengkapi fitur impor jadwal otomatis dari file PDF kampus.

## Daftar Isi

- [Fitur](#fitur)
- [Arsitektur](#arsitektur)
- [Teknologi](#teknologi)
- [Struktur Proyek](#struktur-proyek)
- [Persyaratan Sistem](#persyaratan-sistem)
- [Instalasi & Menjalankan](#instalasi--menjalankan)
- [Cara Penggunaan](#cara-penggunaan)
- [Roadmap Pengembangan](#roadmap-pengembangan)
- [Lisensi](#lisensi)

---

## Fitur

### 1. Profil & Onboarding
- **Onboarding Interaktif** — wizard 3 langkah (Sambutan, Kampus, Target) saat pertama kali membuka aplikasi
- **Profil Mahasiswa** — tampilan dan pengeditan data diri (Nama, Universitas, Program Studi)
- **Target Akademik** — pengaturan semester aktif dan target IPK

### 2. Manajemen Jadwal Kuliah
- **Jadwal Berulang** — input manual jadwal mingguan (Mata Kuliah, Ruangan, Dosen, Jam)
- **Impor PDF Otomatis** — unggah file PDF jadwal kampus, aplikasi akan mengekstrak dan menyimpan data secara otomatis
- **Tampilan Terkelompok** — jadwal ditampilkan per hari dengan kartu berwarna
- **Filter Cepat** — filter berdasarkan hari dan mata kuliah
- **Pengingat Pra-Kelas** — notifikasi otomatis 15/30/60/120 menit sebelum kelas dimulai

### 3. Manajemen Tugas & PR
- **Catatan Tugas** — input judul, deskripsi, relasi mata kuliah, dan tenggat waktu
- **Pelacakan Status** — 3 status: Belum Dimulai, Sedang Dikerjakan, Selesai
- **Penyortiran Cerdas** — tugas paling mendesak otomatis berada di urutan teratas
- **Notifikasi Berjenjang** — pengingat H-3, H-1, dan 3 jam sebelum tenggat
- **Aksi Langsung** — tombol "Kerjakan" / "Selesai" pada notifikasi

### 4. Manajemen Keuangan
- **Buku Kas Digital** — pencatatan pemasukan dan pengeluaran harian
- **Kategori Transaksi** — kategori bawaan (Makanan, Transportasi, Hiburan, dll.) + kategori kustom
- **Visualisasi Grafik** — diagram lingkaran (*pie chart*) alokasi pengeluaran menggunakan `fl_chart`
- **Analisis Keuangan** — rasio pengeluaran terhadap pemasukan dan rekomendasi
- **Batas Anggaran** — penentuan limit mingguan/bulanan dengan peringatan visual

### 5. Pengaturan
- **Tema Gelap/Terang** — *toggle* mode gelap yang tersimpan secara persisten
- **Kustomisasi Notifikasi** — pengaturan pengingat per modul
- **Manajemen Anggaran** — pengaturan batas pengeluaran

---

## Arsitektur

Collagement menggunakan **feature-first clean architecture** dengan tiga lapisan utama:

```
lib/
├── core/           # Lapisan inti (theme, services, shared providers)
├── data/           # Lapisan data (database, repository)
└── features/       # Fitur-fitur aplikasi
    ├── finance/
    ├── home/
    ├── profile/
    ├── schedule/
    ├── settings/
    └── tasks/
```

### Pola Repository

Setiap fitur menerapkan **Repository Pattern** yang memisahkan logika UI dari database. Hal ini memudahkan transisi ke database *online* (Firebase/Supabase) di masa depan — cukup mengganti lapisan *repository* tanpa merombak seluruh kode.

### Manajemen State

**Riverpod** (`flutter_riverpod`) digunakan sebagai *state management* dengan pola `StateNotifier` + `StateNotifierProvider` untuk setiap fitur.

---

## Teknologi

### Framework & Bahasa
- **Flutter** (SDK ^3.12.0)
- **Dart** — bahasa pemrograman

### State Management
| Paket | Versi | Fungsi |
|-------|-------|--------|
| `flutter_riverpod` | ^2.6.1 | State management deklaratif |

### Database & Penyimpanan
| Paket | Versi | Fungsi |
|-------|-------|--------|
| `hive` | ^2.2.3 | Database NoSQL lokal (offline-first) |
| `hive_flutter` | ^1.1.0 | Integrasi Hive dengan Flutter |

### Pemrosesan Dokumen
| Paket | Versi | Fungsi |
|-------|-------|--------|
| `syncfusion_flutter_pdf` | ^33.2.13 | Ekstraksi teks dari file PDF jadwal |
| `file_picker` | ^8.1.4 | Pemilih file untuk impor jadwal |

### Visualisasi
| Paket | Versi | Fungsi |
|-------|-------|--------|
| `fl_chart` | ^1.2.0 | Diagram lingkaran keuangan |

### Notifikasi
| Paket | Versi | Fungsi |
|-------|-------|--------|
| `flutter_local_notifications` | ^22.1.0 | Notifikasi lokal untuk jadwal & tugas |
| `timezone` | ^0.11.1 | Dukungan zona waktu untuk notifikasi terjadwal |

### Lainnya
| Paket | Versi | Fungsi |
|-------|-------|--------|
| `intl` | ^0.20.3 | Format tanggal dan angka |
| `uuid` | ^4.6.0 | Pembuatan ID unik |
| `path_provider` | ^2.1.6 | Akses path direktori perangkat |

### DevOps
| Paket | Fungsi |
|-------|--------|
| `build_runner` | Generator kode (Hive TypeAdapter) |
| `hive_generator` | Generator Hive adapter |
| `flutter_launcher_icons` | Generator ikon aplikasi |
| `flutter_lints` | Aturan *linting* Dart |

---

## Struktur Proyek

```
college-student-management-mobile-app/
├── lib/
│   ├── main.dart                          # Entry point aplikasi
│   ├── core/
│   │   ├── providers/
│   │   │   └── theme_provider.dart        # Provider tema (gelap/terang)
│   │   ├── services/
│   │   │   └── notification_service.dart  # Layanan notifikasi lokal
│   │   └── theme/
│   │       ├── app_colors.dart            # Palet warna aplikasi
│   │       ├── app_text_styles.dart       # Gaya teks aplikasi
│   │       └── app_theme.dart             # Tema Material 3
│   ├── data/
│   │   └── database/
│   │       └── hive_setup.dart            # Inisialisasi Hive & boxes
│   └── features/
│       ├── finance/
│       │   ├── data/models/
│       │   │   └── transaction_model.dart # Model transaksi keuangan
│       │   ├── providers/
│       │   │   └── finance_provider.dart  # State & logika keuangan
│       │   └── presentation/screens/
│       │       └── finance_screen.dart    # Layar keuangan
│       ├── home/
│       │   └── presentation/screens/
│       │       └── home_screen.dart       # Dasbor utama
│       ├── profile/
│       │   ├── data/models/
│       │   │   └── profile_model.dart     # Model profil mahasiswa
│       │   ├── providers/
│       │   │   └── profile_provider.dart  # State profil
│       │   └── presentation/screens/
│       │       ├── onboarding_screen.dart # Wizard onboarding 3 langkah
│       │       └── profile_screen.dart    # Edit profil
│       ├── schedule/
│       │   ├── data/models/
│       │   │   └── schedule_model.dart    # Model jadwal kuliah
│       │   ├── providers/
│       │   │   ├── schedule_provider.dart # State & parser PDF jadwal
│       │   │   └── schedule_reminder_provider.dart  # Pengingat jadwal
│       │   └── presentation/screens/
│       │       └── schedule_screen.dart   # Layar jadwal kuliah
│       ├── settings/
│       │   └── presentation/screens/
│       │       └── settings_screen.dart   # Layar pengaturan
│       └── tasks/
│           ├── data/models/
│           │   └── task_model.dart        # Model tugas
│           ├── providers/
│           │   └── task_provider.dart     # State & logika tugas
│           └── presentation/screens/
│               └── tasks_screen.dart      # Layar manajemen tugas
├── android/
├── ios/
├── web/
├── windows/
├── macos/
├── linux/
├── test/
├── pubspec.yaml                           # Konfigurasi dependensi
├── plan.md                                # Rencana pengembangan
└── logo_collegement.png                   # Logo aplikasi
```

---

## Persyaratan Sistem

- **Flutter SDK**: ^3.12.0
- **Dart SDK**: disertakan dalam Flutter SDK
- **Android**: minSdkVersion 21 (Android 5.0+)
- **iOS**: iOS 12.0+
- **Platform**: Android, iOS, Web, Windows, macOS, Linux

---

## Instalasi & Menjalankan

### 1. Clone repositori

```bash
git clone https://github.com/fatur/college-student-management-mobile-app.git
cd college-student-management-mobile-app
```

### 2. Install dependensi

```bash
flutter pub get
```

### 3. Generate kode (Hive TypeAdapter)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 4. Generate ikon aplikasi *(opsional)*

```bash
dart run flutter_launcher_icons
```

### 5. Jalankan aplikasi

```bash
flutter run
```

> **Catatan**: Aplikasi sepenuhnya *offline-first* — tidak memerlukan konfigurasi server atau API key. Semua data disimpan secara lokal di perangkat.

### Build APK (Android)

```bash
flutter build apk --release
```

### Build IPA (iOS)

```bash
flutter build ios --release
```

---

## Cara Penggunaan

### Pertama Kali Membuka Aplikasi

1. Isi **Nama** pada langkah pertama *onboarding*
2. Masukkan **Universitas** dan **Program Studi**
3. Atur **Semester Aktif** dan **Target IPK**
4. Aplikasi siap digunakan — Anda akan diarahkan ke **Dasbor Utama**

### Menambahkan Jadwal Kuliah

1. Buka halaman **Jadwal** dari dasbor
2. Ketuk tombol **+** untuk menambah jadwal manual
3. Atau ketuk **Impor PDF** untuk mengunggah file PDF jadwal dari kampus
4. Atur pengingat per jadwal (15/30/60/120 menit sebelum kelas)

### Mengelola Tugas

1. Buka halaman **Tugas**
2. Ketuk **+** untuk menambah tugas baru
3. Pilih status tugas (Belum Dimulai / Sedang Dikerjakan / Selesai)
4. Tugas akan terurut otomatis berdasarkan tenggat waktu
5. Notifikasi akan muncul H-3, H-1, dan 3 jam sebelum tenggat

### Mencatat Keuangan

1. Buka halaman **Keuangan**
2. Ketuk **+** untuk menambah transaksi (pemasukan/pengeluaran)
3. Pilih kategori yang sesuai
4. Pantau pengeluaran melalui diagram lingkaran dan kartu ringkasan

---

## Roadmap Pengembangan

| Fase | Fitur | Status |
|------|-------|--------|
| **Fase 1** | Persiapan & setup arsitektur Flutter | Selesai |
| **Fase 2** | Modul onboarding & profil | Selesai |
| **Fase 3** | Modul jadwal, kalender, & tugas (dengan impor PDF) | Selesai |
| **Fase 4** | Sistem notifikasi lokal | Selesai |
| **Fase 5** | Modul keuangan & pengaturan | Selesai |
| **Fase 6** | Testing & rilis APK | Sedang dikerjakan |
| **Fase 7** | Backup & ekspor data (JSON) | Tertunda |
| **Fase 8** | Sinkronisasi cloud (Firebase/Supabase) | Tertunda |

---

## Lisensi

Hak cipta © 2026. Seluruh hak cipta dilindungi undang-undang.

Proyek ini bersifat **privat** dan tidak untuk didistribusikan tanpa izin dari pemilik.
