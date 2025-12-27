import 'package:flutter/material.dart';
import '../models/product_model.dart';

// Class phụ lưu item trong giỏ (kèm số lượng mua)
class CartItem {
  final String productId;
  final String name;
  final double price;
  final String imageUrl;
  int quantity;

  CartItem({
    required this.productId,
    required this.name,
    required this.price,
    required this.imageUrl,
    this.quantity = 1,
  });
}

class CartProvider with ChangeNotifier {
  // Key là productId để dễ tìm kiếm/update
  final Map<String, CartItem> _items = {};

  Map<String, CartItem> get items => _items;

  int get itemCount => _items.length;

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  // Thêm vào giỏ
  void addItem(ProductModel product) {
    if (_items.containsKey(product.productId)) {
      // Nếu đã có -> tăng số lượng
      _items.update(
        product.productId,
        (existing) => CartItem(
          productId: existing.productId,
          name: existing.name,
          price: existing.price,
          imageUrl: existing.imageUrl,
          quantity: existing.quantity + 1,
        ),
      );
    } else {
      // Chưa có -> thêm mới
      _items.putIfAbsent(
        product.productId,
        () => CartItem(
          productId: product.productId,
          name: product.name,
          price: product.price,
          imageUrl: product.imageUrl,
          quantity: 1,
        ),
      );
    }
    notifyListeners();
  }

  // Giảm số lượng
  void removeSingleItem(String productId) {
    if (!_items.containsKey(productId)) return;
    
    if (_items[productId]!.quantity > 1) {
      _items.update(
        productId,
        (existing) => CartItem(
            productId: existing.productId,
            name: existing.name,
            price: existing.price,
            imageUrl: existing.imageUrl,
            quantity: existing.quantity - 1),
      );
    } else {
      _items.remove(productId);
    }
    notifyListeners();
  }

  // Xóa hẳn item khỏi giỏ
  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  // Xóa sạch giỏ (sau khi đặt hàng thành công)
  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}