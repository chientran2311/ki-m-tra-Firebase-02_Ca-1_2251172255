import 'package:cloud_firestore/cloud_firestore.dart';

class ProductModel {
  final String productId;
  final String name;
  final String description;
  final double price;
  final String category;
  final String brand;
  final int stock;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final bool isAvailable;
  final DateTime createdAt;

  ProductModel({
    required this.productId,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    required this.brand,
    required this.stock,
    required this.imageUrl,
    required this.rating,
    required this.reviewCount,
    required this.isAvailable,
    required this.createdAt,
  });

  factory ProductModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ProductModel(
      productId: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      // Ép kiểu num rồi toDouble để tránh lỗi int/double
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] ?? '',
      brand: data['brand'] ?? '',
      stock: data['stock'] ?? 0,
      imageUrl: data['imageUrl'] ?? '',
      rating: (data['rating'] as num?)?.toDouble() ?? 0.0,
      reviewCount: data['reviewCount'] ?? 0,
      isAvailable: data['isAvailable'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
      'category': category,
      'brand': brand,
      'stock': stock,
      'imageUrl': imageUrl,
      'rating': rating,
      'reviewCount': reviewCount,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}