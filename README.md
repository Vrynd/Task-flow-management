# TaskFlow - Modern Task Management Application

TaskFlow adalah aplikasi manajemen tugas (*Task Management*) modern berbasis Flutter yang dirancang dengan antarmuka premium bertema gelap (*Indigo Aurora*). Aplikasi ini membantu pengguna mengelola tugas harian, melacak produktivitas melalui analitik performa, serta mengkategorikan pekerjaan dengan mudah dan efisien.

---

## 🚀 Fitur Utama

Aplikasi ini dilengkapi dengan berbagai fitur premium, antara lain:

1. **Autentikasi & Guarding Rute**:
   - Halaman Login dan Registrasi pengguna.
   - Caching token JWT secara lokal menggunakan `shared_preferences`.
   - Pengalihan rute otomatis (*route guarding*) menggunakan `go_router` berdasarkan status autentikasi aktif.
2. **Dasbor Produktivitas (Home Dashboard)**:
   - Kartu ringkasan statistik tugas (Tugas Selesai, Tertunda, Total Tugas).
   - Pengukur persentase penyelesaian tugas dinamis.
   - Tampilan log riwayat aktivitas terbaru pengguna.
3. **Manajemen Tugas Lengkap (Task CRUD)**:
   - Membuat, membaca, memperbarui, dan menghapus tugas.
   - Pemilihan tingkat prioritas dengan kode warna visual: **Tinggi** (Rose), **Sedang** (Amber), dan **Rendah** (Emerald).
   - Pemilihan tanggal tenggat waktu (*deadline*) dengan pemformatan lokal (`intl` bahasa Indonesia).
   - Pencarian tugas secara real-time dan penyaringan berdasarkan status atau prioritas.
4. **Manajemen Kategori Kustom**:
   - Mengelompokkan tugas berdasarkan kategori (misal: Kerja, Pribadi, Belajar).
   - Pembuatan kategori baru secara dinamis dengan nama dan deskripsi khusus.
5. **Pengaturan Akun & Analitik**:
   - Halaman profil pengguna yang dapat disunting (Nama, Email, Foto).
   - Statistik performa interaktif tentang tingkat penyelesaian tugas.
6. **Navigasi Glassmorphic Modern**:
   - Menggunakan *Floating Navigation Dock* dengan efek blur latar belakang (`BackdropFilter`) dan animasi transisi yang mulus.

---

## 🏛️ Arsitektur Proyek (Feature-First Modular)

Proyek ini menerapkan pendekatan **Feature-First Modular Architecture** untuk memastikan kode tetap bersih, mudah dipelihara, dan skalabel seiring bertambahnya fitur baru.

Struktur folder utama di dalam direktori `lib/` adalah sebagai berikut:

```text
lib/
├── core/
│   ├── routes/      # Sistem routing terpusat menggunakan GoRouter
│   ├── services/    # Layanan global (misal: ApiService untuk koneksi HTTP)
│   └── themes/      # Token desain global (AppColors, AppFont, AppTheme)
├── features/
│   ├── auth/        # Fitur Autentikasi & Manajemen Sesi Pengguna
│   ├── home/        # Fitur Dasbor Utama & Ringkasan Statistik
│   ├── navigation/  # Floating Navigation Dock & Alur Perpindahan Tab
│   ├── settings/    # Pengaturan Profil, Analitik, & Riwayat Aktivitas
│   └── tasks/       # Fitur Pembuatan, Pengeditan, & Filter Tugas
└── main.dart        # Titik masuk utama aplikasi (Entry Point)
```

Setiap modul fitur di dalam `features/` dibagi menjadi sub-layer berikut untuk memisahkan logika bisnis dan UI (*Separation of Concerns*):
- **`models/`**: Representasi struktur data (blueprint object) yang memetakan data JSON dari/ke objek Dart.
- **`services/`**: Menangani panggilan API spesifik untuk fitur tersebut dengan berkomunikasi ke `ApiService`.
- **`providers/`**: Manajemen state menggunakan `ChangeNotifier` (`Provider`) untuk mengelola status UI dan sinkronisasi data.
- **`presentation/`**: Berisi halaman utama (`screens/`) dan widget pendukung (`widgets/`) yang menyusun tampilan antarmuka.

---

## 🛠️ Teknologi & Dependensi Utama

Aplikasi ini dibangun menggunakan **Flutter SDK ^3.9.2** dengan pustaka-pustaka pendukung berikut:

* **[Provider](https://pub.dev/packages/provider)** - Solusi manajemen state untuk mengalirkan data secara reaktif ke seluruh widget.
* **[GoRouter](https://pub.dev/packages/go_router)** - Sistem routing deklaratif untuk Flutter yang memudahkan navigasi dan penanganan deep link.
* **[HTTP](https://pub.dev/packages/http)** - Mengirim permintaan HTTP (GET, POST, PUT, DELETE) ke server backend.
* **[Shared Preferences](https://pub.dev/packages/shared_preferences)** - Menyimpan data lokal sederhana seperti token autentikasi dan pengaturan preferensi.
* **[HugeIcons](https://pub.dev/packages/hugeicons)** - Set ikon vektor modern dengan visual *clean* dan minimalis.
* **[Google Fonts](https://pub.dev/packages/google_fonts)** - Memuat font modern secara dinamis untuk estetika tipografi premium.
* **[Intl](https://pub.dev/packages/intl)** - Mendukung pemformatan tanggal dan pelokalan bahasa (Bahasa Indonesia `id_ID`).

---

## 🏁 Memulai & Cara Menjalankan

Ikuti langkah-langkah di bawah ini untuk menjalankan proyek ini di lingkungan lokal Anda:

### 1. Prasyarat
Pastikan Anda sudah menginstal:
- [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.9.2 atau lebih baru)
- Android Studio / VS Code dengan ekstensi Flutter dan Dart terpasang
- Emulator Android/iOS atau perangkat fisik yang terhubung

### 2. Konfigurasi Backend API
Aplikasi ini terhubung ke backend server melalui `ApiService`.
1. Buka file `lib/core/services/api_service.dart`.
2. Temukan variabel `baseUrl`:
   ```dart
   static const String baseUrl = 'http://192.168.43.100:3000';
   ```
3. Ubah alamat IP tersebut dengan alamat IP lokal server backend Anda. (Jika Anda menjalankan emulator Android, gunakan `http://10.0.2.2:3000` untuk merujuk ke localhost komputer Anda).

### 3. Instalasi Dependensi
Jalankan perintah berikut di terminal root proyek Anda untuk mengunduh pustaka yang diperlukan:
```bash
flutter pub get
```

### 4. Menjalankan Aplikasi
Gunakan perintah berikut untuk menjalankan aplikasi pada emulator atau perangkat yang aktif:
```bash
flutter run
```

---

## 👥 Tim Pengembang

Proyek ini dibangun dan dikembangkan oleh:

- **Rifky Verryan Dhika** (NPM: 5230411112)
- **Revaldo Ilham Maulana** (NPM: 5230411134)
- **Made Widhiyana** (NPM: 5230411138)
- **Louis Mahardhika** (NPM: 5230411139)
- **Ardian Anugrah Pratama** (NPM: 5230411140)
