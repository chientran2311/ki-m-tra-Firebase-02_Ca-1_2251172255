import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/order_model.dart';

class OrderRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String collection = 'orders';

  Future<void> createOrder(OrderModel order) async {
    print("--- BẮT ĐẦU TẠO ĐƠN HÀNG ---");
    return _db.runTransaction((transaction) async {
      // DANH SÁCH TẠM ĐỂ LƯU KẾT QUẢ ĐỌC
      List<DocumentSnapshot> productSnapshots = [];

      // --- PHA 1: ĐỌC TẤT CẢ DỮ LIỆU (READ ONLY) ---
      // Phải đọc hết trước khi thực hiện bất kỳ lệnh ghi nào
      for (var item in order.items) {
        DocumentReference productRef = _db.collection('products').doc(item.productId);
        try {
          DocumentSnapshot snapshot = await transaction.get(productRef);
          productSnapshots.add(snapshot);
        } catch (e) {
          throw Exception("Lỗi khi đọc sản phẩm ${item.productId}: $e");
        }
      }

      // --- PHA 2: KIỂM TRA LOGIC & TÍNH TOÁN ---
      for (int i = 0; i < order.items.length; i++) {
        var item = order.items[i];
        var snapshot = productSnapshots[i]; // Lấy snapshot tương ứng đã đọc ở trên

        if (!snapshot.exists) {
          throw Exception("Sản phẩm '${item.productName}' không tồn tại!");
        }

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        int currentStock = (data['stock'] as num).toInt();

        print("Check: ${item.productName} - Kho: $currentStock - Mua: ${item.quantity}");

        if (currentStock < item.quantity) {
          throw Exception("Sản phẩm '${item.productName}' không đủ hàng (Còn: $currentStock)!");
        }
      }

      // --- PHA 3: GHI DỮ LIỆU (WRITE ONLY) ---
      // Sau khi đã kiểm tra tất cả đều ổn, mới tiến hành trừ kho
      for (int i = 0; i < order.items.length; i++) {
        var item = order.items[i];
        var snapshot = productSnapshots[i];
        DocumentReference productRef = _db.collection('products').doc(item.productId);
        
        int currentStock = (snapshot.get('stock') as num).toInt();
        
        transaction.update(productRef, {
          'stock': currentStock - item.quantity,
          'isAvailable': (currentStock - item.quantity) > 0
        });
      }

      // Cuối cùng là tạo đơn hàng
      DocumentReference orderRef = _db.collection(collection).doc();
      Map<String, dynamic> orderData = order.toMap();
      orderData['orderDate'] = FieldValue.serverTimestamp();
      
      transaction.set(orderRef, orderData);
      print("--- GIAO DỊCH HOÀN TẤT ---");
    });
  }

  // ... (Giữ nguyên các hàm updateOrderStatus, getOrdersByCustomer cũ) ...
    // 2. Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String newStatus) async {
    if (newStatus == 'cancelled') {
      await _db.runTransaction((transaction) async {
        DocumentReference orderRef = _db.collection(collection).doc(orderId);
        DocumentSnapshot orderSnap = await transaction.get(orderRef);
        
        if (!orderSnap.exists) throw Exception("Đơn hàng không tồn tại");
        
        String currentStatus = orderSnap.get('status');
        if (currentStatus == 'cancelled') throw Exception("Đơn hàng đã bị hủy trước đó");

        List<dynamic> items = orderSnap.get('items');
        
        // Tương tự: Phải đọc hết Product trước khi Update
        // Nhưng logic hủy đơn thường ít khi lỗi hơn vì ít conflict, 
        // tuy nhiên để an toàn bạn cũng nên tách read/write nếu cần.
        // Ở đây code cũ tạm ổn vì ta update từng product một cách độc lập logic.
        // Để chuẩn xác nhất cho logic Hủy Đơn:
        
        List<DocumentSnapshot> prodSnaps = [];
        for (var item in items) {
           String pid = item['productId'];
           prodSnaps.add(await transaction.get(_db.collection('products').doc(pid)));
        }

        // Write loop
        for (int i=0; i<items.length; i++) {
           var item = items[i];
           var snap = prodSnaps[i];
           if(snap.exists) {
             int currentStock = (snap.get('stock') as num).toInt();
             transaction.update(snap.reference, {
                'stock': currentStock + item['quantity'],
                'isAvailable': true
             });
           }
        }
        
        transaction.update(orderRef, {'status': 'cancelled'});
      });
    } else {
      await _db.collection(collection).doc(orderId).update({'status': newStatus});
    }
  }

  Stream<List<OrderModel>> getOrdersByCustomer(String customerId) {
    return _db
        .collection(collection)
        .where('customerId', isEqualTo: customerId)
        .orderBy('orderDate', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => OrderModel.fromFirestore(doc)).toList());
  }

  Future<OrderModel?> getOrderById(String orderId) async {
    DocumentSnapshot doc = await _db.collection(collection).doc(orderId).get();
    if(doc.exists) return OrderModel.fromFirestore(doc);
    return null;
  }
}