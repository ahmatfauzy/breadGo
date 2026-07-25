# BreadGo API Documentation

> **Dokumen utama**: `api_contract.md` — kontrak endpoint yang HARUS dipatuhi oleh agent Backend dan Flutter.
> **Shared types**: `shared_types.md` — definisi tipe TypeScript & Dart yang identik.
> **Spesifikasi proyek**: `spesifikasi.md` — kasus dan unit kompetensi.

- **Base URL**: `http://<HOST>:5000/api/v1`
- **Auth**: JWT Bearer Token
- **Content-Type**: `application/json`

---

## Ringkasan Endpoint

| Method | Path | Auth | Role | Deskripsi |
|--------|------|------|------|-----------|
| GET | `/health` | No | - | Cek status server |
| POST | `/auth/register` | No | - | Registrasi user |
| POST | `/auth/login` | No | - | Login user |
| GET | `/auth/me` | Yes | - | Profil user login |
| GET | `/products` | No | - | List produk |
| GET | `/products/:id` | No | - | Detail produk |
| POST | `/products` | Yes | admin | Tambah produk |
| PUT | `/products/:id` | Yes | admin | Update produk |
| DELETE | `/products/:id` | Yes | admin | Hapus produk |
| POST | `/orders` | Yes | - | Buat pesanan |
| GET | `/orders` | Yes | - | List pesanan user |
| GET | `/orders/:id` | Yes | - | Detail pesanan |
| PATCH | `/orders/:id/status` | Yes | admin | Update status pesanan |
| GET | `/admin/orders` | Yes | admin | List semua pesanan |
| GET | `/admin/orders/:id` | Yes | admin | Detail pesanan (admin) |

---

## Response Envelope

```json
// Success
{ "success": true, "data": {...} }

// Error
{ "success": false, "message": "..." }
```

---

## Detail lengkap lihat:
- **api_contract.md** — spesifikasi request/response setiap endpoint
- **shared_types.md** — interface TypeScript + class Dart
