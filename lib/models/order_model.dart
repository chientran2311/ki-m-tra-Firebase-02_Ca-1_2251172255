import 'package:cloud_firestore/cloud_firestore.dart';

// Class phụ để xử lý từng món hàng trong đơn
class OrderItem {
  final String productId;
  final String productName;
  final int quantity;
  final double price;

  OrderItem({
    required this.productId,
    required this.productName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromMap(Map<String, dynamic> data) {
    return OrderItem(
      productId: data['productId'] ?? '',
      productName: data['productName'] ?? '',
      quantity: data['quantity'] ?? 0,
      price: (data['price'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'productName': productName,
      'quantity': quantity,
      'price': price,
    };
  }
}

class OrderModel {
  final String orderId;
  final String customerId;
  final List<OrderItem> items; // Danh sách sản phẩm
  final double subtotal;
  final double shippingFee;
  final double total;
  final DateTime orderDate;
  final String shippingAddress;
  final String status;
  final String paymentMethod;
  final String paymentStatus;
  final String? notes;

  OrderModel({
    required this.orderId,
    required this.customerId,
    required this.items,
    required this.subtotal,
    required this.shippingFee,
    required this.total,
    required this.orderDate,
    required this.shippingAddress,
    required this.status,
    required this.paymentMethod,
    required this.paymentStatus,
    this.notes,
  });

  factory OrderModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    
    // Convert Array of Maps từ Firestore thành List<OrderItem>
    var listItems = data['items'] as List<dynamic>? ?? [];
    List<OrderItem> parsedItems = listItems.map((item) => OrderItem.fromMap(item)).toList();

    return OrderModel(
      orderId: doc.id,
      customerId: data['customerId'] ?? '',
      items: parsedItems,
      subtotal: (data['subtotal'] as num?)?.toDouble() ?? 0.0,
      shippingFee: (data['shippingFee'] as num?)?.toDouble() ?? 0.0,
      total: (data['total'] as num?)?.toDouble() ?? 0.0,
      orderDate: (data['orderDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      shippingAddress: data['shippingAddress'] ?? '',
      status: data['status'] ?? 'pending',
      paymentMethod: data['paymentMethod'] ?? 'cash',
      paymentStatus: data['paymentStatus'] ?? 'pending',
      notes: data['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'customerId': customerId,
      // Convert List object thành List Map để lưu Firestore
      'items': items.map((e) => e.toMap()).toList(),
      'subtotal': subtotal,
      'shippingFee': shippingFee,
      'total': total,
      'orderDate': Timestamp.fromDate(orderDate),
      'shippingAddress': shippingAddress,
      'status': status,
      'paymentMethod': paymentMethod,
      'paymentStatus': paymentStatus,
      'notes': notes,
    };
  }
}