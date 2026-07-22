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

  CreateProductRequest({
    required this.name,
    required this.description,
    required this.price,
    required this.imageUrl,
    required this.category,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'description': description,
        'price': price,
        'imageUrl': imageUrl,
        'category': category,
      };
}
