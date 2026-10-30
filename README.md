# 🌊 BlastSafe
### Aplikasi Informasi & Monitoring Lokasi Perlindungan pada Kondisi Darurat Banjir
**Desa Konversi & Tangguh Bencana**

---

## 📋 Deskripsi
BlastSafe adalah aplikasi mobile berbasis Flutter/Dart yang dirancang untuk membantu warga desa dalam menghadapi kondisi darurat banjir. Aplikasi ini menampilkan status wilayah secara real-time, lokasi shelter evakuasi, panduan keselamatan, kontak darurat, dan fitur laporan warga.

---

## 🚀 Cara Menjalankan di VS Code

### Prasyarat
1. **Flutter SDK** — Download dari https://flutter.dev/docs/get-started/install
2. **Dart SDK** — Sudah termasuk dalam Flutter SDK
3. **VS Code** dengan ekstensi:
   - Flutter
   - Dart
4. **Android Studio** (untuk Android Emulator) atau device fisik Android/iOS

### Langkah Instalasi & Menjalankan

```bash
# 1. Extract project ke folder lokal, lalu buka terminal di folder tersebut
cd blastsafe_v3

# 2. Install semua dependencies
flutter pub get

# 3. Pastikan emulator/device sudah aktif, lalu jalankan
flutter run
```

### Menjalankan di VS Code (cara mudah)
1. Buka folder `blastsafe_v3` di VS Code (`File > Open Folder`)
2. Buka file `lib/main.dart`
3. Pastikan emulator Android sudah berjalan (atau sambungkan HP lewat USB dengan Developer Mode aktif)
4. Tekan **F5** atau klik tombol **▶️ Run** di pojok kanan atas
5. Pilih device target

### Build APK untuk dirilis / didownload orang lain

```bash
# Build APK release (file bisa langsung di-install di HP Android)
flutter build apk --release

# File APK tersimpan di:
# build/app/outputs/flutter-apk/app-release.apk
```

Bagikan file `app-release.apk` tersebut lewat Google Drive, WhatsApp, email, dll. Orang lain tinggal install APK-nya di HP Android.

---

## 📱 Fitur Aplikasi

### 🏠 Beranda (Home)
- Status wilayah real-time (Aman/Waspada/Siaga/Bahaya)
- Info cuaca & kondisi terkini
- Menu utama: Info Cuaca, Shelter, Panduan, Kontak Darurat
- Tips persiapan banjir
- Laporan warga terkini
- Pop-up peringatan otomatis saat status bukan "Aman"

### 🏘️ Shelter & Evakuasi
- Daftar posko evakuasi dengan jarak dari lokasi user
- Status ketersediaan kapasitas (Tersedia/Hampir Penuh/Penuh)
- Detail shelter: alamat, telepon, kapasitas terisi
- Filter berdasarkan ketersediaan
- Tombol navigasi dan hubungi

### 📋 Panduan Keselamatan
- Tab Persiapan: Tips sebelum banjir, daftar isi tas darurat
- Tab Saat Banjir: Langkah-langkah keselamatan step-by-step
- Tab Pasca Banjir: Panduan pemulihan yang aman

### 📞 Kontak Darurat
- Nomor darurat: BPBD (119), Ambulans (118), Damkar (113), Polisi (110)
- Kontak lokal: Relawan Desa, Kepala Desa

### 📝 Laporan Warga
- Form kirim laporan kondisi lapangan
- Daftar laporan masuk dari warga
- Status verifikasi laporan

### 🛡️ Admin Panel
- Akses tersembunyi untuk operator desa
- Update Status Wilayah: Aman/Waspada/Siaga/Bahaya + pesan untuk warga
- Kelola Kapasitas Shelter: Update jumlah pengungsi per posko
- Verifikasi Laporan Warga: Konfirmasi kebenaran laporan

---

## 📂 Struktur Project
```
blastsafe_v3/
├── lib/
│   ├── main.dart                 # Entry point aplikasi
│   ├── theme.dart                # Definisi warna & tema
│   ├── models/
│   │   └── app_models.dart       # Model data
│   ├── data/
│   │   └── app_provider.dart     # State management & data
│   └── screens/
│       ├── splash_screen.dart    # Halaman loading
│       ├── main_navigation.dart  # Bottom navigation
│       ├── home_screen.dart      # Beranda
│       ├── shelter_screen.dart   # Lokasi Shelter
│       ├── panduan_screen.dart   # Panduan Banjir
│       ├── kontak_screen.dart    # Kontak Darurat
│       ├── laporan_screen.dart   # Laporan Warga
│       └── admin_screen.dart     # Dashboard Admin
├── pubspec.yaml                  # Konfigurasi & dependencies
└── README.md                     # Dokumentasi ini
```

---

## 🔧 Dependencies
- `provider` — State management
- `shared_preferences` — Penyimpanan lokal
- `url_launcher` — Buka URL/telepon
- `intl` — Format tanggal/waktu
- `flutter_animate` — Animasi smooth

---

## 💡 Catatan Pengembangan
Aplikasi ini menggunakan data statis untuk demo/tugas. Untuk implementasi nyata, perlu:
1. Backend server (Firebase/Supabase/REST API)
2. Notifikasi push (FCM)
3. GPS real-time
4. Integrasi dengan sistem BMKG

---

*BlastSafe © 2025 — Desa Konversi & Tangguh Bencana*
