# 🍞 BreadGo

BreadGo adalah aplikasi _mobile_ untuk penjualan roti dan kue secara _online_. Aplikasi ini memungkinkan pelanggan untuk melihat katalog produk terbaru beserta harganya, dan melakukan pemesanan secara langsung. BreadGo juga dilengkapi dengan fitur pelacakan lokasi berbasis GPS untuk merekam titik koordinat pengiriman pelanggan dengan akurat.

---

## 🏗 Struktur Proyek

```text
BreadGo/
├── app/
│   ├── mobile/      # Aplikasi Mobile (Frontend)
│   └── services/    # Layanan API (Backend)
└── docs/            # Dokumentasi & Spesifikasi Proyek
```

---

## 💻 Tech Stack

### 📱 Frontend (Mobile App)

- **Framework**: [Flutter](https://flutter.dev/) (Dart)
- **Arsitektur & State Management**: GetX Pattern (Di-generate dengan GetX CLI)
- **Fitur Utama**: Antarmuka responsif, penyimpanan lokal (SQLite/Shared Preferences), dan integrasi LBS (_Location Based Services_) GPS.

### ⚙️ Backend (API Services)

- **Runtime**: [Node.js](https://nodejs.org/) v24+
- **Framework**: [Express.js](https://expressjs.com/)
- **Bahasa Pemrograman**: [TypeScript](https://www.typescriptlang.org/)
- **ORM**: [Prisma](https://www.prisma.io/)
- **Database**: [Turso (libSQL)](https://turso.tech/), SQLite

---

## 🚀 Cara Menjalankan (Getting Started)

### 1. Menjalankan Backend (API Services)

Pastikan Anda memiliki Node.js terinstal.

```bash
# Masuk ke direktori backend
cd app/services

# Instal dependensi
npm install

# Buat file .env dan sesuaikan konfigurasi (DATABASE_URL, JWT_SECRET, dll)
cp .env.example .env

# Jalankan server dalam mode development (dengan hot-reload menggunakan tsx)
npm run dev
```

Server akan berjalan di `http://localhost:5000` (atau _port_ sesuai konfigurasi `.env`).

### 2. Menjalankan Frontend (Mobile App)

Pastikan Anda sudah menginstal Flutter SDK dan menyiapkan emulator atau perangkat fisik.

```bash
# Masuk ke direktori mobile
cd app/mobile

# Ambil semua package Flutter
flutter pub get

# Jalankan aplikasi
flutter run
```

---

_Proyek ini dirancang untuk memenuhi unit kompetensi BNSP junior mobile dev._
