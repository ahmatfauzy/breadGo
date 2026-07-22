# BreadGo — Agent Assignment

Proyek ini dikerjakan oleh **2 AI Agent** secara paralel:

| Agent | Stack | Direktori |
|-------|-------|-----------|
| **Agent Services** | Node.js / Express / TypeScript / Prisma / Turso | `app/services/` |
| **Agent Flutter** | Flutter / Dart / GetX | `app/mobile/` |

---

## Aturan Utama

Kedua agent bekerja MANDIRI. Tidak boleh saling menimpa file agent lain. Komunikasi antar agent HANYA melalui kontrak yang sudah disepakati di direktori `docs/`.

**Kontrak tidak boleh dilanggar:**
- Nama endpoint, method, request body, response body HARUS sesuai `docs/api_contract.md`
- Nama field, tipe data, struktur JSON HARUS sesuai `docs/shared_types.md`
- Backend hanya mengubah `app/services/`, Flutter hanya mengubah `app/mobile/`
- Jika butuh perubahan kontrak, ubah `docs/api_contract.md` atau `docs/shared_types.md` terlebih dahulu, lalu kedua agent menyesuaikan

---

## Agent Services (Backend)

**Tugas**: Implementasi REST API untuk BreadGo.

### Dokumen wajib dibaca:
1. `docs/spesifikasi.md` — kasus bisnis & unit kompetensi
2. `docs/api_contract.md` — 15 endpoint lengkap (request/response/error)
3. `docs/shared_types.md` — interface TypeScript (section TS)
4. `docs/api_endpoints.md` — ringkasan cepat endpoint

### Yang sudah ada:
- Express app skeleton (`app.ts`, `server.ts`)
- Auth (register/login/me) dengan JWT — `authRoutes.ts`, `authController.ts`, `authMiddleware.ts`
- Prisma client + Turso/libSQL connection — `utils/prisma.ts`
- User model di `prisma/schema.prisma`

### Yang harus dikerjakan:
1. Perbarui `prisma/schema.prisma` (Product, Order, OrderItem — sudah ada di schema, pastikan sesuai)
2. `npx prisma generate` untuk generate client
3. Buat migration / push schema ke Turso
4. Buat controller + routes untuk:
   - Products (CRUD)
   - Orders (create, list, detail)
   - Admin orders (list all, detail, update status)
5. Tambahkan middleware `adminOnly` untuk role-based access
6. Seed data produk roti (minimal 5-8 produk)
7. Validasi input di setiap endpoint

### Pola kode yang harus diikuti:
- Struktur: `controllers/` → `routes/` → daftar di `routes/index.ts`
- Response format: `{ success: boolean, data?: ..., message?: string }`
- Error: throw error dengan status code, ditangkap `errorHandler.ts`
- Auth: pakai `protect` middleware dari `authMiddleware.ts`

---

## Agent Flutter (Frontend)

**Tugas**: Implementasi UI mobile untuk BreadGo.

### Dokumen wajib dibaca:
1. `docs/spesifikasi.md` — kasus bisnis & unit kompetensi
2. `docs/api_contract.md` — 15 endpoint lengkap (request/response/error)
3. `docs/shared_types.md` — class Dart (section Dart)
4. `docs/api_endpoints.md` — ringkasan cepat endpoint

### Yang sudah ada:
- Flutter project skeleton dengan GetX pattern
- Routing (`app/routes/`)
- Module home (binding, controller, view)

### Yang harus dikerjakan:
1. Tambahkan dependency: `http`, `geolocator`, `shared_preferences` / `flutter_secure_storage`
2. Buat service layer untuk HTTP client (`lib/app/services/api_client.dart`)
3. Buat model class sesuai `docs/shared_types.md` (semua section Dart)
4. Buat module GetX:
   - **Auth**: login, register, profil — `modules/auth/`
   - **Products**: katalog, detail — `modules/products/`
   - **Orders**: checkout (form + GPS), riwayat, detail — `modules/orders/`
   - **Admin**: dashboard pesanan, update status — `modules/admin/`
5. Izin GPS di `AndroidManifest.xml` dan `Info.plist`
6. Ambil koordinat GPS via `geolocator` sebelum POST `/orders`
7. Simpan token JWT, cek role user, tampilkan/sembunyikan menu admin

### Pola kode yang harus diikuti:
- GetX: `bindings/` → `controllers/` → `views/`
- API call di controller, state pakai `.obs`
- Model class di `lib/app/models/`
- Service di `lib/app/services/`
- Base URL config: `http://10.0.2.2:5000/api/v1` (Android emulator) atau `http://localhost:5000/api/v1`

---

## Koordinasi

| Jika... | Maka... |
|---------|---------|
| Backend ubah response shape | Update `docs/api_contract.md` + `docs/shared_types.md`, Flutter menyesuaikan model |
| Flutter butuh endpoint baru | Diskusikan dulu, tambah ke `docs/api_contract.md`, backend implementasi |
| Ada perubahan schema DB | Update `prisma/schema.prisma`, backend migrate, update `shared_types.md` |

---

## Struktur Proyek

```
BreadGo/
├── AGENTS.md                  # ← file ini
├── docs/
│   ├── spesifikasi.md         # Kasus & unit kompetensi
│   ├── api_contract.md        # KONTRAK: 15 endpoint lengkap
│   ├── shared_types.md        # KONTRAK: TS interface + Dart class
│   └── api_endpoints.md       # Ringkasan cepat
├── app/
│   ├── services/              # ← Agent Services (Backend)
│   │   ├── prisma/
│   │   │   └── schema.prisma  # DB schema
│   │   ├── src/
│   │   │   ├── controllers/
│   │   │   ├── middleware/
│   │   │   ├── routes/
│   │   │   └── utils/
│   │   └── package.json
│   └── mobile/                # ← Agent Flutter (Frontend)
│       └── lib/
│           └── app/
│               ├── modules/
│               ├── routes/
│               └── services/  # (belum ada — harus dibuat)
```
