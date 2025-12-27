import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/customer_model.dart';
import '../services/firestore_service.dart';

class CustomerRepository {
  final FirebaseFirestore _db = FirestoreService().db;
  final String collection = 'customers';

  // 1. Thêm Customer
  Future<void> addCustomer(CustomerModel customer) async {
    await _db.collection(collection).doc(customer.customerId).set(customer.toMap());
  }

  // 2. Lấy Customer theo ID
  Future<CustomerModel?> getCustomerById(String id) async {
    DocumentSnapshot doc = await _db.collection(collection).doc(id).get();
    if (doc.exists) {
      return CustomerModel.fromFirestore(doc);
    }
    return null;
  }

  // 3. Lấy tất cả Customers
  Stream<List<CustomerModel>> getAllCustomers() {
    return _db.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => CustomerModel.fromFirestore(doc)).toList();
    });
  }

  // 4. Cập nhật Customer
  Future<void> updateCustomer(CustomerModel customer) async {
    await _db.collection(collection).doc(customer.customerId).update(customer.toMap());
  }

  // 5. Xóa Customer (Kiểm tra ràng buộc)
  Future<void> deleteCustomer(String customerId) async {
    // Kiểm tra xem user có đơn hàng đang xử lý không ("pending", "confirmed", "processing", "shipped")
    QuerySnapshot activeOrders = await _db
        .collection('orders')
        .where('customerId', isEqualTo: customerId)
        .where('status', whereIn: ['pending', 'confirmed', 'processing', 'shipped'])
        .get();

    if (activeOrders.docs.isNotEmpty) {
      throw Exception('Không thể xóa: Khách hàng đang có đơn hàng chưa hoàn tất.');
    }

    await _db.collection(collection).doc(customerId).delete();
  }
}