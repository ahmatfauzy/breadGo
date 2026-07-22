class OrderItemRequest {
  final String productId;
  final int quantity;

  OrderItemRequest({required this.productId, required this.quantity});

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'quantity': quantity,
      };
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

class OrderItemResponse {
  final String id;
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItemResponse({
    required this.id,
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItemResponse.fromJson(Map<String, dynamic> json) =>
      OrderItemResponse(
        id: json['id'],
        productId: json['productId'],
        productName: json['productName'],
        quantity: json['quantity'],
        price: (json['price'] as num).toDouble(),
      );
}

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
        items: (json['items'] as List)
            .map((i) => OrderItemResponse.fromJson(i))
            .toList(),
      );
}

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

  factory AdminOrderResponse.fromJson(Map<String, dynamic> json) =>
      AdminOrderResponse(
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
        items: (json['items'] as List)
            .map((i) => OrderItemResponse.fromJson(i))
            .toList(),
      );
}

class UpdateOrderStatusRequest {
  final String status;

  UpdateOrderStatusRequest({required this.status});

  Map<String, dynamic> toJson() => {'status': status};
}
