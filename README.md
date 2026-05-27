# Domino Hansip

<img src="assets/images/app_logo.png" alt="Domino Hansip Logo" width="160">

Domino Hansip adalah aplikasi Flutter untuk membantu mencatat jalannya permainan domino: pembagian batu, pass, pemenang game, perpindahan Kepala Desa, status Hansip, riwayat game, dan statistik pemain.

Aplikasi ini dibuat untuk menggantikan catatan manual saat bermain, sehingga pemain cukup fokus ke permainan sementara aplikasi menjaga urutan ronde dan perhitungan batu.

## Fitur Utama

- Setup 3 sampai 6 pemain dengan nama dan warna avatar.
- Konfigurasi jumlah batu sebelum game dimulai.
- Alur pengambilan batu dari stok tengah.
- Catatan pass dan distribusi batu antar pemain.
- Aturan Batu Besar hanya bisa dibagikan terakhir.
- Penyelesaian game saat stok habis dan ada pemain tanpa batu.
- Pemilihan pemenang game.
- Penentuan Kepala Desa dan Hansip setelah game selesai.
- Riwayat hasil tiap game.
- Statistik pemain, termasuk kemenangan, Hansip, Kepala Desa, batu dibagikan, dan batu diterima.
- Penyimpanan state lokal, sehingga game aktif bisa dilanjutkan setelah aplikasi ditutup.

## Aturan Yang Didukung

- Stok awal berisi 1 Batu Besar dan sisanya Batu Kecil.
- Nilai Batu Kecil adalah 1 poin.
- Nilai Batu Besar adalah 5 poin.
- Batu Besar hanya boleh dibagikan ketika pemain sudah tidak punya Batu Kecil.
- Game bisa diselesaikan ketika stok tengah habis dan minimal satu pemain sudah tidak punya batu.
- Pemenang dipilih manual saat game selesai.
- Kepala Desa berpindah ke pemenang jika pemenang memenuhi syarat tanpa batu setelah penyelesaian game.
- Hansip ditentukan dari pemain dengan poin tertinggi. Jika seri, aplikasi meminta pilihan manual.

## Tech Stack

- Flutter
- Dart
- flutter_bloc untuk state management
- hydrated_bloc untuk persistensi state lokal
- equatable untuk value comparison
- google_fonts untuk typography
- uuid untuk ID data game

## Struktur Project

```text
lib/
  app/                 Konfigurasi app, router, dan theme
  core/                Constants, utility, extension, dan reusable widgets
  data/models/         Model data game, pemain, action, history, settlement
  features/
    game_setup/        Setup pemain dan jumlah batu
    game_table/        Meja permainan, pass, distribusi batu, state utama
    round_settlement/  Pemilihan pemenang dan ringkasan game selesai
    history/           Riwayat hasil game
    statistics/        Statistik pemain
    home/              Beranda dan akses lanjutkan game
    splash/            Splash screen
```

## Menjalankan Project

Pastikan Flutter SDK sudah terpasang, lalu jalankan:

```bash
flutter pub get
flutter run
```

Untuk memastikan kode bersih:

```bash
dart format lib
flutter analyze
flutter test
```

## Asset

Logo aplikasi berada di:

```text
assets/images/app_logo.png
```

Asset tersebut sudah didaftarkan di `pubspec.yaml`.

## Status

Project ini adalah aplikasi mobile lokal untuk pencatatan permainan Domino Hansip. Data game aktif disimpan di perangkat menggunakan Hydrated BLoC, sehingga pemain dapat keluar ke beranda atau menutup aplikasi lalu melanjutkan game yang sama.
