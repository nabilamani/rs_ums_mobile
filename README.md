# RS UMS Mobile

Aplikasi mobile Rumah Sakit UMS berbasis Flutter untuk membantu pengguna mengakses informasi rumah sakit, artikel kesehatan, jadwal dokter, dan presensi digital.

## Fitur

- Onboarding aplikasi pada penggunaan pertama.
- Registrasi dan login dengan email/password menggunakan Firebase Authentication.
- Login dengan Google.
- Reset password melalui email.
- Beranda dengan informasi singkat dan akses cepat.
- Daftar, pencarian, dan detail artikel dari REST API.
- Jadwal dokter dari REST API.
- Presensi check-in dan check-out menggunakan Firebase Firestore.
- Validasi presensi berdasarkan:
  - pengguna yang sedang login;
  - hari kerja Senin-Jumat;
  - satu presensi per hari;
  - jarak maksimal 100 meter dari koordinat rumah sakit.
- Riwayat dan statistik presensi.
- Dukungan lokasi, geocoding, dan permission pada perangkat.

## Teknologi

| Komponen | Teknologi |
| --- | --- |
| Framework | Flutter |
| Bahasa | Dart |
| Autentikasi | Firebase Authentication |
| Database presensi | Cloud Firestore |
| HTTP client | Dio |
| State management | Provider |
| Lokasi | Geolocator, Geocoding, Permission Handler |
| Format tanggal | Intl |
| Penyimpanan lokal | Shared Preferences |
| Platform | Android, iOS, Web, Windows, macOS, Linux |

## Persyaratan Sistem

Sebelum memulai, instal:

- Flutter SDK yang mendukung Dart SDK `^3.9.2`.
- Android Studio dan Android SDK untuk Android, atau Xcode untuk iOS/macOS.
- Git.
- Akun dan project Firebase.
- Backend REST API RS UMS yang dapat diakses dari perangkat atau emulator.

Periksa instalasi Flutter:

```bash
flutter doctor
flutter --version
```

## Instalasi

1. Clone repository dan masuk ke folder project:

   ```bash
   git clone <URL_REPOSITORY>
   cd rs_ums_test
   ```

2. Ambil dependency:

   ```bash
   flutter pub get
   ```

3. Pastikan konfigurasi Firebase tersedia. File `lib/firebase_options.dart` digunakan oleh aplikasi saat inisialisasi Firebase. Jika file tersebut belum ada, buat dengan FlutterFire CLI:

   ```bash
   dart pub global activate flutterfire_cli
   flutterfire configure
   ```

   Pilih Firebase project yang benar dan platform yang akan digunakan. Untuk Android, konfigurasi project juga menggunakan `android/app/google-services.json`.

4. Aktifkan layanan Firebase berikut pada Firebase Console:

   - Authentication: Email/Password dan Google.
   - Cloud Firestore.

5. Konfigurasi URL backend pada `lib/utils/constants.dart`:

   ```dart
   static const String baseUrl = 'http://192.168.167.141:8000';
   ```

   Ganti alamat tersebut dengan alamat backend yang dapat dijangkau oleh perangkat. `localhost` dari emulator/perangkat tidak selalu menunjuk ke komputer development. Pastikan backend menyediakan endpoint `/api/v1/articles` dan `/api/v1/schedules`.

6. Untuk presensi, sesuaikan koordinat dan radius rumah sakit pada `lib/services/location_service.dart`:

   ```dart
   static const double hospitalLatitude = -7.571465;
   static const double hospitalLongitude = 110.874745;
   static const double allowedRadiusInMeters = 100.0;
   ```

## Menjalankan Aplikasi

Lihat device yang tersedia:

```bash
flutter devices
```

Jalankan dalam mode development:

```bash
flutter run
```

Jalankan pada device tertentu:

```bash
flutter run -d <device-id>
```

Build release:

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# Web
flutter build web --release

# iOS (macOS saja)
flutter build ios --release
```

## Alur Penggunaan

1. Pengguna membuka aplikasi dan menyelesaikan onboarding.
2. Pengguna login atau membuat akun baru.
3. Setelah berhasil login, pengguna masuk ke beranda.
4. Dari navigasi utama, pengguna dapat membuka beranda, jadwal, informasi/artikel, dan akun.
5. Presensi dilakukan melalui halaman presensi:
   - izinkan akses lokasi;
   - lakukan check-in pada hari kerja dan di area yang diizinkan;
   - lakukan check-out setelah selesai.
6. Data presensi tersimpan pada koleksi Firestore `presensi` berdasarkan `userId`.

## Konfigurasi Firebase

### Authentication

Aktifkan provider **Email/Password** dan **Google** di Firebase Console. Untuk Google Sign-In:

- Android memerlukan SHA-1/SHA-256 dari signing key yang sesuai.
- iOS memerlukan konfigurasi URL scheme Google Sign-In dari Firebase.
- Web memerlukan domain aplikasi yang sudah diizinkan pada Firebase Authentication.

### Firestore

Aplikasi menggunakan koleksi:

```text
presensi
```

Dokumen presensi menyimpan antara lain `userId`, `userEmail`, `tanggal`, `checkIn`, `checkOut`, `status`, lokasi check-in, dan lokasi check-out. Terapkan Firestore Security Rules yang hanya mengizinkan pengguna membaca dan mengubah data miliknya. Jangan gunakan rules terbuka pada production.

## Konfigurasi Lokasi

Permission lokasi telah dideklarasikan pada Android dan iOS. Pengguna tetap harus:

- mengaktifkan Location Services;
- memberikan izin lokasi;
- menggunakan perangkat dengan GPS yang cukup akurat;
- berada dalam radius yang dikonfigurasi dari rumah sakit.

Pada Android, permission background location tercantum di manifest. Tinjau kembali kebutuhan dan kebijakan distribusi aplikasi sebelum mengaktifkan fitur lokasi di background pada production.

## Struktur Project

```text
lib/
├── main.dart                         # Bootstrap Firebase, theme, routing, provider
├── features/
│   └── presensi/
│       ├── domain/
│       │   ├── models/                # Model data presensi
│       │   └── repositories/          # Firestore dan validasi presensi
│       └── presentation/
│           ├── pages/                 # Halaman presensi
│           └── providers/             # State management presensi
├── models/                            # Model artikel
├── screens/                           # Halaman onboarding, auth, home, jadwal, informasi, akun
├── services/
│   ├── api_service.dart               # Client REST API berbasis Dio
│   ├── auth_service.dart              # Firebase Auth dan Google Sign-In
│   └── location_service.dart          # Permission, GPS, jarak, geocoding
├── utils/
│   ├── constants.dart                 # URL API, warna, ukuran, timeout
│   └── date_formatter.dart            # Format tanggal
└── widgets/                           # Komponen UI yang dapat digunakan ulang
assets/
└── icon/                              # Logo aplikasi dan Google
```

## API Backend

Base URL dikonfigurasi pada `ApiConstants.baseUrl`. Endpoint yang digunakan aplikasi:

| Method | Endpoint | Kegunaan |
| --- | --- | --- |
| `GET` | `/api/v1/articles?page={page}` | Mengambil daftar artikel |
| `GET` | `/api/v1/articles/{slug}` | Mengambil detail artikel |
| `GET` | `/api/v1/articles?search={query}` | Mencari artikel |
| `GET` | `/api/v1/schedules` | Mengambil jadwal dokter |

Respons artikel diharapkan mengikuti struktur yang dipetakan oleh `Article`, `ArticlesResponse`, dan `ArticleDetailResponse`. Backend juga perlu mengizinkan request dari client yang digunakan, terutama saat menjalankan versi web.

## Pengujian dan Analisis

Jalankan formatter dan analyzer:

```bash
dart format lib
flutter analyze
```

Jalankan test yang tersedia:

```bash
flutter test
```

Jika folder `test/` belum tersedia, validasi utama dapat dilakukan dengan `flutter analyze` dan pengujian manual pada emulator/perangkat.

## Troubleshooting

### `firebase_options.dart` tidak ditemukan

Jalankan `flutterfire configure` dan pastikan file hasil konfigurasi berada di `lib/firebase_options.dart`.

### Artikel atau jadwal tidak dapat dimuat

- Pastikan backend sedang berjalan.
- Pastikan `baseUrl` menggunakan IP/hostname yang dapat dijangkau perangkat.
- Pastikan endpoint menggunakan prefix `/api/v1`.
- Periksa koneksi jaringan dan log Dio pada output aplikasi.

### Presensi ditolak karena lokasi

- Aktifkan GPS/Location Services.
- Berikan permission lokasi.
- Periksa koordinat rumah sakit dan radius pada `LocationService`.
- Pastikan mock location atau emulator location menunjuk ke area yang benar.

### Google Sign-In gagal

Periksa provider Google di Firebase, package name/bundle identifier, SHA-1/SHA-256 Android, serta konfigurasi platform hasil `flutterfire configure`.

### Firestore permission denied

Periksa Firestore Security Rules dan pastikan pengguna sudah terautentikasi. Query presensi menggunakan field `userId` yang sama dengan UID Firebase Authentication.

## Catatan Keamanan

- Jangan memasukkan credential service account atau secret backend ke aplikasi Flutter.
- URL HTTP lokal hanya cocok untuk development. Gunakan HTTPS untuk production.
- Batasi akses Firestore berdasarkan UID pengguna.
- Jangan mengandalkan validasi radius di client sebagai satu-satunya kontrol keamanan jika presensi memiliki dampak administratif.
- Tinjau ulang konfigurasi signing release sebelum distribusi; konfigurasi Android saat ini masih menggunakan debug signing untuk release.

## Kontribusi

1. Buat branch fitur dari branch utama.
2. Ikuti struktur dan konvensi Dart/Flutter yang sudah ada.
3. Jalankan `dart format`, `flutter analyze`, dan test yang relevan.
4. Buat pull request dengan ringkasan perubahan dan langkah pengujian.

## Lisensi

Lisensi project belum ditentukan. Tambahkan file `LICENSE` sebelum project didistribusikan secara publik.
