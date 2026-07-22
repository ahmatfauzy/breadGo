# BreadGo API Contract

> **Kontrak bersama** antara agent Backend (Express/TS) dan agent Frontend (Flutter/GetX).
> Setiap endpoint yang tertulis di sini WAJIB diimplementasikan oleh backend dan WAJIB dipanggil oleh frontend sesuai spesifikasi.

- **Base URL**: `http://<HOST>:5000/api/v1`
- **Content-Type**: `application/json`
- **Auth Header**: `Authorization: Bearer <JWT_TOKEN>`

---

## Konvensi Response

Semua response mengikuti format:

```json
{
  "success": true,
  "data": { ... }
}
```

```json
{
  "success": false,
  "message": "Deskripsi error"
}
```

| Field | Tipe | Keterangan |
|-------|------|------------|
| `success` | `boolean` | `true` jika berhasil |
| `data` | `object`/`array` | Payload response (hanya jika success) |
| `message` | `string` | Pesan error (hanya jika gagal) |
| `error` | `object` | Detail error (dari global error handler, hanya jika gagal) |

---

## 1. Health Check

### GET /health

Status server.

- **Auth**: No

**Response `200`**:
```json
{
  "status": "UP",
  "timestamp": "2026-07-22T00:00:00.000Z",
  "uptime": 123.45
}
```

---

## 2. Authentication

### POST /auth/register

Registrasi user baru.

- **Auth**: No

**Request Body**:
```json
{
  "name": "string (required)",
  "email": "string (required, valid email)",
  "password": "string (required, min 6)"
}
```

**Response `201`**:
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "id": "uuid",
    "name": "string",
    "email": "string",
    "token": "jwt-string"
  }
}
```

**Error**:
| Status | Message |
|--------|---------|
| 400 | `Please provide all required fields` |
| 400 | `User already exists` |

---

### POST /auth/login

Login user.

- **Auth**: No

**Request Body**:
```json
{
  "email": "string (required)",
  "password": "string (required)"
}
```

**Response `200`**:
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": "uuid",
    "name": "string",
    "email": "string",
    "token": "jwt-string"
  }
}
```

**Error**:
| Status | Message |
|--------|---------|
| 400 | `Please provide email and password` |
| 401 | `Invalid credentials` |

---

### GET /auth/me

Profil user yang sedang login.

- **Auth**: Yes

**Response `200`**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "email": "string",
    "role": "customer" | "admin",
    "createdAt": "ISO8601"
  }
}
```

**Error**:
| Status | Message |
|--------|---------|
| 401 | `Not authorized, no token provided` |
| 401 | `Not authorized, token failed` |

---

## 3. Products (Katalog Roti)

### GET /products

List semua produk aktif.

- **Auth**: No

**Query Params**:
| Param | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `category` | `string` | - | Filter: `bread` / `cake` |
| `search` | `string` | - | Cari nama produk |

**Response `200`**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "name": "Roti Coklat",
      "description": "Roti lembut isi coklat",
      "price": 15000,
      "imageUrl": "https://...",
      "category": "bread",
      "isActive": true,
      "createdAt": "ISO8601"
    }
  ]
}
```

---

### GET /products/:id

Detail satu produk.

- **Auth**: No

**Response `200`**:
```json
{
  "success": true,
  "data": {
    "id": "uuid",
    "name": "string",
    "description": "string",
    "price": 15000,
    "imageUrl": "string",
    "category": "bread" | "cake",
    "isActive": true,
    "createdAt": "ISO8601"
  }
}
```

**Error**:
| Status | Message |
|--------|---------|
| 404 | `Product not found` |

---

### POST /products

Tambah produk baru (admin only).

- **Auth**: Yes (role: admin)

**Request Body**:
```json
{
  "name": "string (required)",
  "description": "string (required)",
  "price": 15000,
  "imageUrl": "string (required)",
  "category": "bread"
}
```

**Response `201`**:
```json
{
  "success": true,
  "message": "Product created",
  "data": { ...product }
}
```

---

### PUT /products/:id

Update produk (admin only).

- **Auth**: Yes (role: admin)

**Request Body** (semua optional):
```json
{
  "name": "string",
  "description": "string",
  "price": 15000,
  "imageUrl": "string",
  "category": "bread",
  "isActive": true
}
```

**Response `200`**:
```json
{
  "success": true,
  "message": "Product updated",
  "data": { ...product }
}
```

---

### DELETE /products/:id

Hapus produk (soft-delete: set isActive=false) (admin only).

- **Auth**: Yes (role: admin)

**Response `200`**:
```json
{
  "success": true,
  "message": "Product deleted"
}
```

---

## 4. Orders (Pemesanan)

### POST /orders

Buat pesanan baru dengan data pelanggan + koordinat GPS.

- **Auth**: Yes

**Request Body**:
```json
{
  "customerName": "string (required)",
  "customerPhone": "string (required)",
  "customerAddress": "string (required)",
  "latitude": -6.2088,
  "longitude": 106.8456,
  "items": [
    {
      "productId": "uuid (required)",
      "quantity": 2
    }
  ]
}
```

**Response `201`**:
```json
{
  "success": true,
  "message": "Order created",
  "data": {
    "id": "uuid",
    "userId": "uuid",
    "customerName": "string",
    "customerPhone": "string",
    "customerAddress": "string",
    "latitude": -6.2088,
    "longitude": 106.8456,
    "totalAmount": 30000,
    "status": "pending",
    "createdAt": "ISO8601",
    "items": [
      {
        "id": "uuid",
        "productId": "uuid",
        "productName": "Roti Coklat",
        "quantity": 2,
        "price": 15000
      }
    ]
  }
}
```

**Error**:
| Status | Message |
|--------|---------|
| 400 | `Please provide all required fields` |
| 400 | `Items cannot be empty` |
| 404 | `Product not found: <id>` |

---

### GET /orders

List pesanan user yang sedang login.

- **Auth**: Yes

**Response `200`**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "customerName": "string",
      "customerPhone": "string",
      "customerAddress": "string",
      "latitude": -6.2088,
      "longitude": 106.8456,
      "totalAmount": 30000,
      "status": "pending" | "confirmed" | "delivered" | "cancelled",
      "createdAt": "ISO8601",
      "items": [
        {
          "id": "uuid",
          "productId": "uuid",
          "productName": "string",
          "quantity": 2,
          "price": 15000
        }
      ]
    }
  ]
}
```

---

### GET /orders/:id

Detail satu pesanan user.

- **Auth**: Yes (hanya pemilik order)

**Response `200`**: Sama seperti item di array GET /orders

**Error**:
| Status | Message |
|--------|---------|
| 404 | `Order not found` |
| 403 | `Not authorized to view this order` |

---

### PATCH /orders/:id/status

Update status pesanan (admin only).

- **Auth**: Yes (role: admin)

**Request Body**:
```json
{
  "status": "confirmed"
}
```

Nilai valid: `pending`, `confirmed`, `delivered`, `cancelled`

**Response `200`**:
```json
{
  "success": true,
  "message": "Order status updated",
  "data": { ...order }
}
```

---

## 5. Admin

### GET /admin/orders

List SEMUA pesanan dari seluruh user. Untuk dashboard admin.

- **Auth**: Yes (role: admin)

**Query Params**:
| Param | Tipe | Default | Keterangan |
|-------|------|---------|------------|
| `status` | `string` | - | Filter: `pending` / `confirmed` / `delivered` / `cancelled` |

**Response `200`**:
```json
{
  "success": true,
  "data": [
    {
      "id": "uuid",
      "userId": "uuid",
      "userName": "string",
      "userEmail": "string",
      "customerName": "string",
      "customerPhone": "string",
      "customerAddress": "string",
      "latitude": -6.2088,
      "longitude": 106.8456,
      "totalAmount": 30000,
      "status": "pending",
      "createdAt": "ISO8601",
      "items": [
        {
          "id": "uuid",
          "productId": "uuid",
          "productName": "string",
          "quantity": 2,
          "price": 15000
        }
      ]
    }
  ]
}
```

---

### GET /admin/orders/:id

Detail satu pesanan (admin — bisa lihat semua).

- **Auth**: Yes (role: admin)

**Response `200`**: Sama seperti item di GET /admin/orders

---

## Rangkuman Endpoint

| Method | Path | Auth | Role |
|--------|------|------|------|
| GET | `/health` | No | - |
| POST | `/auth/register` | No | - |
| POST | `/auth/login` | No | - |
| GET | `/auth/me` | Yes | - |
| GET | `/products` | No | - |
| GET | `/products/:id` | No | - |
| POST | `/products` | Yes | admin |
| PUT | `/products/:id` | Yes | admin |
| DELETE | `/products/:id` | Yes | admin |
| POST | `/orders` | Yes | - |
| GET | `/orders` | Yes | - |
| GET | `/orders/:id` | Yes | - |
| PATCH | `/orders/:id/status` | Yes | admin |
| GET | `/admin/orders` | Yes | admin |
| GET | `/admin/orders/:id` | Yes | admin |

---

## Aturan untuk Agent Backend

1. Semua endpoint di atas HARUS ada. Tidak boleh kurang.
2. Format response HARUS sesuai konvensi: `{ success, data }` atau `{ success, message }`.
3. Validasi input di setiap endpoint (field required, tipe data).
4. Auth middleware HARUS memeriksa `role` untuk endpoint admin.
5. `POST /orders` HARUS menghitung `totalAmount` dari `items[].quantity * product.price`.
6. `DELETE /products` hanya soft-delete (`isActive = false`), tidak hapus record.
7. Response list order HARUS menyertakan `productName` (join ke Product).

## Aturan untuk Agent Flutter

1. Base URL HARUS dikonfigurasi (default: `http://10.0.2.2:5000/api/v1` untuk Android emulator).
2. Semua request HARUS menggunakan header `Content-Type: application/json`.
3. Token JWT disimpan di secure storage / shared preferences.
4. Setiap response `success: false` HARUS ditampilkan ke user (Snackbar/AlertDialog).
5. GPS koordinat HARUS diambil dari `geolocator` package sebelum POST `/orders`.
6. Role user HARUS dicek untuk menampilkan/menyembunyikan fitur admin.
7. Semua model class HARUS mengikuti definisi di `shared_types.md`.
