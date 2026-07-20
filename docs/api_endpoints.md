# BreadGo API Documentation

Dokumen ini berisi spesifikasi *endpoint* untuk BreadGo API Services. Semua request dan response menggunakan format JSON.

- **Base URL**: `http://localhost:5000/api/v1`

---

## 1. System Health

### 1.1 Cek Status Server
Memeriksa apakah layanan API sedang berjalan (UP) atau tidak.

- **URL**: `/health`
- **Method**: `GET`
- **Auth Required**: No

**Success Response (200 OK):**
```json
{
  "status": "UP",
  "timestamp": "2026-07-20T07:27:18.123Z",
  "uptime": 12.34
}
```

---

## 2. Authentication

### 2.1 Pendaftaran Pengguna (Register)
Mendaftarkan akun pengguna baru ke dalam sistem.

- **URL**: `/auth/register`
- **Method**: `POST`
- **Auth Required**: No

**Request Body:**
```json
{
  "name": "Nama Lengkap",
  "email": "user@example.com",
  "password": "rahasia123"
}
```

**Success Response (201 Created):**
```json
{
  "success": true,
  "message": "User registered successfully",
  "data": {
    "id": "uuid-v4-string",
    "name": "Nama Lengkap",
    "email": "user@example.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5c..."
  }
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "User already exists"
}
```

---

### 2.2 Masuk (Login)
Autentikasi pengguna untuk mendapatkan JSON Web Token (JWT).

- **URL**: `/auth/login`
- **Method**: `POST`
- **Auth Required**: No

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "rahasia123"
}
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Login successful",
  "data": {
    "id": "uuid-v4-string",
    "name": "Nama Lengkap",
    "email": "user@example.com",
    "token": "eyJhbGciOiJIUzI1NiIsInR5c..."
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Invalid credentials"
}
```

---

### 2.3 Profil Pengguna (Get Me)
Mengambil detail profil pengguna yang sedang aktif/login.

- **URL**: `/auth/me`
- **Method**: `GET`
- **Auth Required**: Yes (Bearer Token)

**Headers:**
```
Authorization: Bearer <TOKEN_JWT>
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "data": {
    "id": "uuid-v4-string",
    "name": "Nama Lengkap",
    "email": "user@example.com",
    "createdAt": "2026-07-20T07:27:18.123Z"
  }
}
```

**Error Response (401 Unauthorized):**
```json
{
  "success": false,
  "message": "Not authorized, token failed"
}
```
