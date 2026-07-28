# Rencana Pengembangan Aplikasi Manajemen Perkuliahan (College Student Management Mobile App)

## 1. Pendahuluan
Aplikasi ini bertujuan untuk membantu mahasiswa dalam mengelola aktivitas perkuliahan secara komprehensif, mulai dari penjadwalan kelas, manajemen tugas, hingga pengelolaan keuangan pribadi yang disesuaikan dengan gaya hidup mahasiswa.

## 2. Arsitektur & Teknologi (Keputusan Final)
Berdasarkan diskusi, berikut adalah teknologi dan arsitektur yang akan digunakan dalam pengembangan:
- **Framework Aplikasi Mobile**: **Flutter** (Dipilih karena memberikan performa native yang baik dan UI yang konsisten di berbagai perangkat).
- **State Management**: **Provider** atau **Riverpod** (sangat cocok untuk aplikasi berskala menengah hingga besar pada arsitektur Flutter).
- **Database Utama**: **Offline-first** menggunakan database lokal seperti **Hive** (NoSQL yang sangat cepat) atau **SQLite / sqflite** (Relasional). 
  *Catatan Penting*: Karena ada kemungkinan aplikasi akan diubah menjadi *online* (Cloud DB) di masa depan, kita akan menggunakan **Repository Pattern**. Pola ini akan memisahkan logika UI dari database, sehingga nanti saat beralih ke Firebase/Supabase, kita hanya perlu mengubah satu lapisan *repository* tanpa harus merombak seluruh kode aplikasi.
- **Notifikasi**: **flutter_local_notifications** untuk penjadwalan alarm pengingat murni di sisi perangkat tanpa memerlukan koneksi internet.

## 3. Rincian Modul dan Fitur

### 3.1. Modul Profil Pengguna (Offline Mode)
- **Onboarding Pengguna**:
  - Karena tidak membutuhkan sinkronisasi ke server untuk rilis awal, fitur registrasi (email/password) ditiadakan terlebih dahulu. Diganti dengan *screen onboarding* di mana pengguna mengisi nama dan universitas saat pertama kali membuka aplikasi.
- **Profil Mahasiswa**:
  - Halaman untuk melihat dan mengedit informasi dasar (Nama, Universitas, Program Studi).
  - Input untuk menetapkan semester aktif dan target nilai/IPK.

### 3.2. Modul Jadwal & Kalender Akademik
- **Manajemen Jadwal Berulang**:
  - Formulir penambahan kelas (Mata Kuliah, Ruangan, Nama Dosen, Jam, Hari).
  - Logika agar jadwal ini otomatis terulang setiap minggunya pada hari yang sama.
- **Tampilan Kalender**:
  - Komponen kalender interaktif.
  - Opsi tampilan harian (agenda) dan mingguan (time-blocking) agar jadwal mudah dipindai.
- **Pengingat Pra-Kelas**:
  - Sistem *background task* / penjadwalan notifikasi lokal 50 menit - 1 jam sebelum setiap kelas dimulai.
- **Impor Jadwal Kuliah Otomatis (via PDF)**:
  - Fitur unggah file PDF jadwal kuliah dari kampus (misal: `jadwal-semester-2.pdf`).
  - Pemrosesan dan ekstraksi dokumen untuk membaca data dari tabel jadwal dengan kolom: HARI, JAM KE, WAKTU, KODE MK, NAMA MK, TE/PR, KODE DOSEN, NAMA DOSEN, Ruangan, dan KELAS.
  - Data yang diekstrak akan disimpan ke dalam database aplikasi dan otomatis terhubung dengan sistem notifikasi pengingat jadwal.
  - UI/UX yang canggih, interaktif, dan modern untuk menampilkan jadwal perkuliahan secara visual.
  - Dukungan pembaruan semester: pengguna dapat mengunggah file PDF jadwal semester baru, dan aplikasi akan memproses serta me-replace/update jadwal lama secara otomatis.
- **Impor Kalender Akademik Otomatis (via PDF)**:
  - Fitur unggah file PDF kalender akademik resmi dari kampus (misal: `kalender-kampus-semester-3-dan-4.pdf`).
  - Pemrosesan dan ekstraksi dokumen PDF untuk membaca tabel kegiatan dengan kolom: TANGGAL, BULAN, TAHUN, dan NAMA KEGIATAN.
  - Data kalender akademik akan disimpan secara lokal dan secara otomatis diintegrasikan ke sistem notifikasi sebagai pengingat untuk kegiatan di tanggal yang bersangkutan.
  - Dukungan pembaruan: Sama halnya dengan jadwal kuliah, pengguna dapat memperbarui agenda dengan mengunggah file PDF kalender akademik untuk semester atau tahun ajaran yang baru.

### 3.3. Modul Manajemen Tugas dan PR
- **Formulir Input Tugas**:
  - Halaman khusus untuk mencatat judul tugas, deskripsi, relasi mata kuliah, dan *deadline* (tanggal & jam).
- **Pelacakan Status**:
  - Pengelompokan tugas berdasarkan status: "Belum Dimulai", "Sedang Dikerjakan", dan "Selesai" (menggunakan UI berbasis kartu/daftar).
- **Penyortiran Cerdas**:
  - Algoritma yang secara otomatis mengurutkan tugas yang paling mendesak di urutan teratas.
- **Notifikasi Berjenjang**:
  - Penjadwalan notifikasi bertahap secara lokal: H-3, H-1, dan 3 jam sebelum *deadline*.

### 3.4. Modul Keuangan Mahasiswa
- **Buku Kas Digital**:
  - Antarmuka pencatatan untuk uang masuk (uang saku/gaji) dan uang keluar.
- **Kategorisasi Transaksi**:
  - Kategori standar (Makanan, Transportasi, Kebutuhan Tugas, Hiburan, dll) dengan opsi penambahan kategori manual.
- **Dasbor Analisis Visual**:
  - Halaman ringkasan keuangan yang menampilkan *Pie Chart* atau grafik batang untuk visualisasi alokasi pengeluaran.
- **Limit dan Peringatan Anggaran**:
  - Fitur penentuan batas anggaran (mingguan/bulanan).
  - Sistem *alert* visual (atau notifikasi lokal) ketika pengeluaran sudah mendekati batas anggaran yang ditetapkan.

### 3.5. Modul Pengaturan (Settings)
- **Kustomisasi Notifikasi**:
  - Halaman pengaturan dengan *toggle switch* untuk menghidupkan/mematikan notifikasi per modul.
- **Tampilan Antarmuka (Theme)**:
  - Dukungan kustomisasi tema aplikasi (*Light Mode* dan *Dark Mode*).
- **Persiapan Transisi Cloud (Eksplorasi)**:
  - Fitur sederhana untuk *Backup* atau *Export* data lokal berformat JSON, agar saat nanti sistem Cloud diimplementasi, pengguna tidak kehilangan data lokal mereka.

## 4. Fase Pengembangan (Roadmap Diperbarui)

- **Fase 1: Persiapan & Setup Arsitektur Flutter**
  - Inisialisasi proyek Flutter.
  - Setup *Repository Pattern* dan inisiasi database lokal (Hive/SQLite).
  - Pembuatan *design system* dasar (warna, *font*, *theme*).
- **Fase 2: Modul Onboarding & Profil (Local Storage)**
  - Pembuatan *UI onboarding* awal dan penyimpanan data profil sederhana ke *local storage*.
- **Fase 3: Modul Jadwal, Kalender, & Tugas (Core Features)**
  - Setup *schema/model* database untuk jadwal kuliah, kalender kegiatan, dan tugas.
  - Integrasi pustaka kalender, implementasi CRUD jadwal & tugas, serta logika penyortiran.
  - Riset dan integrasi pustaka/library pemroses PDF untuk mengekstrak data dari tabel PDF jadwal kuliah dan kalender akademik.
- **Fase 4: Sistem Notifikasi Lokal**
  - Implementasi plugin *flutter_local_notifications* dan penyambungan dengan alarm kelas & tugas.
- **Fase 5: Modul Keuangan & Pengaturan**
  - Implementasi CRUD keuangan, pembuatan diagram (*Pie Chart*), pengaturan batas anggaran, dan integrasi mode *Dark/Light*.
- **Fase 6: Testing & Rilis**
  - Pengujian aplikasi secara menyeluruh dan perbaikan *bug*.
  - Persiapan rilis APK (versi Offline) yang siap digunakan.
