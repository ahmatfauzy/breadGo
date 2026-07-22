# BreadGo Shared Types

> **Kontrak tipe data** yang HARUS identik antara Backend (TypeScript) dan Frontend (Dart).
> Backend menghasilkan data sesuai interface TS. Frontend membuat model class Dart sesuai definisi di sini.
> JANGAN menyimpang dari field dan tipe yang sudah disepakati.

---

## Response Envelope

Semua response API terbungkus dalam envelope ini.

### TypeScript

```ts
interface ApiResponse<T> {
  success: boolean;
  data?: T;
  message?: string;
}
```

### Dart

```dart
class ApiResponse<T> {
  final bool success;
  final T? data;
  final String? message;

  ApiResponse({required this.success, this.data, this.message});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : null,
      message: json['message'],
    );
  }
}
```

---

## Auth

### RegisterRequest / LoginRequest

**TS**:
```ts
interface RegisterRequest {
  name: string;
  email: string;
  password: string;
}

interface LoginRequest {
  email: string;
  password: string;
}
```

**Dart**:
```dart
class RegisterRequest {
  final String name;
  final String email;
  final String password;

  RegisterRequest({required this.name, required this.email, required this.password});

  Map<String, dynamic> toJson() => {'name': name, 'email': email, 'password': password};
}

class LoginRequest {
  final String email;
  final String password;

  LoginRequest({required this.email, required this.password});

  Map<String, dynamic> toJson() => {'email': email, 'password': password};
}
```

### AuthData

**TS**:
```ts
interface AuthData {
  id: string;
  name: string;
  email: string;
  token: string;
}
```

**Dart**:
```dart
class AuthData {
  final String id;
  final String name;
  final String email;
  final String token;

  AuthData({required this.id, required this.name, required this.email, required this.token});

  factory AuthData.fromJson(Map<String, dynamic> json) => AuthData(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    token: json['token'],
  );
}
```

### UserProfile

**TS**:
```ts
interface UserProfile {
  id: string;
  name: string;
  email: string;
  role: 'customer' | 'admin';
  createdAt: string;
}
```

**Dart**:
```dart
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String role;
  final String createdAt;

  UserProfile({required this.id, required this.name, required this.email, required this.role, required this.createdAt});

  factory UserProfile.fromJson(Map<String, dynamic> json) => UserProfile(
    id: json['id'],
    name: json['name'],
    email: json['email'],
    role: json['role'],
    createdAt: json['createdAt'],
  );

  bool get isAdmin => role == 'admin';
}
```

---

## Product

**TS**:
```ts
interface Product {
  id: string;
  name: string;
  description: string;
  price: number;
  imageUrl: string;
  category: 'bread' | 'cake';
  isActive: boolean;
  createdAt: string;
}

interface CreateProductRequest {
  name: string;
  description: string;
  price: number;
  imageUrl: string;
  category: string;
}

interface UpdateProductRequest {
  name?: string;
  description?: string;
  price?: number;
  imageUrl?: string;
  category?: string;
  isActive?: boolean;
}
```

**Dart**:
```dart
class Product {
  final String id;
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;
  final bool isActive;
  final String createdAt;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
    required this.isActive,
    required this.createdAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) => Product(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    price: (json['price'] as num).toDouble(),
    imageUrl: json['imageUrl'],
    category: json['category'],
    isActive: json['isActive'],
    createdAt: json['createdAt'],
  );
}

class CreateProductRequest {
  final String name;
  final String description;
  final double price;
  final String imageUrl;
  final String category;

  CreateProductRequest({required this.name, required this.description, required this.price, required this.imageUrl, required this.category});

  Map<String, dynamic> toJson() => {'name': name, 'description': description, 'price': price, 'imageUrl': imageUrl, 'category': category};
}
```

---

## Order

### CreateOrderRequest

**TS**:
```ts
interface OrderItemRequest {
  productId: string;
  quantity: number;
}

interface CreateOrderRequest {
  customerName: string;
  customerPhone: string;
  customerAddress: string;
  latitude: number;
  longitude: number;
  items: OrderItemRequest[];
}
```

**Dart**:
```dart
class OrderItemRequest {
  final String productId;
  final int quantity;

  OrderItemRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {'productId': productId, 'quantity': quantity};
}

class CreateOrderRequest {
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double latitude;
  final double longitude;
  final List<OrderItemRequest> items;

  CreateOrderRequest({
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.latitude,
    required this.longitude,
    required this.items,
  });

  Map<String, dynamic> toJson() => {
    'customerName': customerName,
    'customerPhone': customerPhone,
    'customerAddress': customerAddress,
    'latitude': latitude,
    'longitude': longitude,
    'items': items.map((i) => i.toJson()).toList(),
  };
}
```

### OrderItemResponse

**TS**:
```ts
interface OrderItemResponse {
  id: string;
  productId: string;
  productName: string;
  quantity: number;
  price: number;
}
```

**Dart**:
```dart
class OrderItemResponse {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItemResponse({required this.id, required this.productId, required this.productName, required this.quantity, required this.price});

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) => OrderItemResponse(
    id: json['id'],
    productId: json['productId'],
    productName: json['productName'],
    quantity: json['quantity'],
    price: (json['price'] as num).toDouble(),
  );
}
```

### OrderResponse

**TS**:
```ts
type OrderStatus = 'pending' | 'confirmed' | 'delivered' | 'cancelled';

interface OrderResponse {
  id: string;
  userId: string;
  customerName: string;
  customerPhone: string;
  customerAddress: string;
  latitude: number;
  longitude: number;
  totalAmount: number;
  status: OrderStatus;
  createdAt: string;
  items: OrderItemResponse[];
}
```

**Dart**:
```dart
class OrderResponse {
  final String id;
  final String userId;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double latitude;
  final double longitude;
  final double totalAmount;
  final String status;
  final String createdAt;
  final List<OrderItemResponse> items;

  OrderResponse({
    required this.id,
    required this.userId,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.latitude,
    required this.longitude,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) => OrderResponse(
    id: json['id'],
    userId: json['userId'],
    customerName: json['customerName'],
    customerPhone: json['customerPhone'],
    customerAddress: json['customerAddress'],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    totalAmount: (json['totalAmount'] as num).toDouble(),
    status: json['status'],
    createdAt: json['createdAt'],
    items: (json['items'] as List).map((i) => OrderItemResponse.fromJson(i)).toList(),
  );
}
```

### AdminOrderResponse

**TS**:
```ts
interface AdminOrderResponse extends OrderResponse {
  userName: string;
  userEmail: string;
}
```

**Dart**:
```dart
class AdminOrderResponse {
  final String id;
  final String userId;
  final String userName;
  final String userEmail;
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final double latitude;
  final double longitude;
  final double totalAmount;
  final String status;
  final String createdAt;
  final List<OrderItemResponse> items;

  AdminOrderResponse({
    required this.id,
    required this.userId,
    required this.userName,
    required this.userEmail,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.latitude,
    required this.longitude,
    required this.totalAmount,
    required this.status,
    required this.createdAt,
    required this.items,
  });

  factory AdminOrderResponse.fromJson(Map<String, dynamic> json) => AdminOrderResponse(
    id: json['id'],
    userId: json['userId'],
    userName: json['userName'],
    userEmail: json['userEmail'],
    customerName: json['customerName'],
    customerPhone: json['customerPhone'],
    customerAddress: json['customerAddress'],
    latitude: (json['latitude'] as num).toDouble(),
    longitude: (json['longitude'] as num).toDouble(),
    totalAmount: (json['totalAmount'] as num).toDouble(),
    status: json['status'],
    createdAt: json['createdAt'],
    items: (json['items'] as List).map((i) => OrderItemResponse.fromJson(i)).toList(),
  );
}
```

### UpdateOrderStatusRequest

**TS**:
```ts
interface UpdateOrderStatusRequest {
  status: OrderStatus;
}
```

**Dart**:
```dart
class UpdateOrderStatusRequest {
  final String status;
  UpdateOrderStatusRequest({required this.status});
  Map<String, dynamic> toJson() => {'status': status};
}
```

---

## Pemetaan Field DB ke Response

| DB Field | OrderResponse | AdminOrderResponse |
|----------|--------------|-------------------|
| `Order.id` | `id` | `id` |
| `Order.userId` | `userId` | `userId` |
| `User.name` | - | `userName` |
| `User.email` | - | `userEmail` |
| `Order.customerName` | `customerName` | `customerName` |
| `Order.customerPhone` | `customerPhone` | `customerPhone` |
| `Order.customerAddress` | `customerAddress` | `customerAddress` |
| `Order.latitude` | `latitude` | `latitude` |
| `Order.longitude` | `longitude` | `longitude` |
| `Order.totalAmount` | `totalAmount` | `totalAmount` |
| `Order.status` | `status` | `status` |
| `Order.createdAt` | `createdAt` | `createdAt` |
| `OrderItem.id` | `items[].id` | `items[].id` |
| `OrderItem.productId` | `items[].productId` | `items[].productId` |
| `Product.name` | `items[].productName` | `items[].productName` |
| `OrderItem.quantity` | `items[].quantity` | `items[].quantity` |
| `OrderItem.price` | `items[].price` | `items[].price` |
