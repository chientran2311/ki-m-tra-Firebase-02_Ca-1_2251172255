import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/product_model.dart';
import '../services/firestore_service.dart';

class ProductRepository {
  final FirebaseFirestore _db = FirestoreService().db;
  final String collection = 'products';

  // 1. Thêm Product
  Future<void> addProduct(ProductModel product) async {
    // Nếu productId rỗng thì để Firestore tự tạo ID
    if (product.productId.isEmpty) {
        await _db.collection(collection).add(product.toMap());
    } else {
        await _db.collection(collection).doc(product.productId).set(product.toMap());
    }
  }

  // 2. Lấy tất cả Products (Realtime)
  Stream<List<ProductModel>> getAllProducts() {
    return _db.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    });
  }

  // 3. Lấy Product theo ID
  Future<ProductModel?> getProductById(String id) async {
    DocumentSnapshot doc = await _db.collection(collection).doc(id).get();
    if (doc.exists) {
      return ProductModel.fromFirestore(doc);
    }
    return null;
  }
  
  // 4. Cập nhật Product
  Future<void> updateProduct(ProductModel product) async {
      await _db.collection(collection).doc(product.productId).update(product.toMap());
  }

  // 5. Tìm kiếm Products (Tìm trong name, description, brand)
  // Lưu ý: Firestore không hỗ trợ tìm kiếm 'contains' (LIKE %...%) native tốt.
  // Với bài thi số lượng ít, ta lấy về và lọc ở Client (Dart).
  Future<List<ProductModel>> searchProducts(String query) async {
    QuerySnapshot snapshot = await _db.collection(collection).get();
    List<ProductModel> allProducts = snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList();
    
    if (query.isEmpty) return allProducts;

    String lowerQuery = query.toLowerCase();
    return allProducts.where((p) {
      return p.name.toLowerCase().contains(lowerQuery) ||
             p.description.toLowerCase().contains(lowerQuery) ||
             p.brand.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // 6. Lọc theo Category
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _db
        .collection(collection)
        .where('category', isEqualTo: category)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => ProductModel.fromFirestore(doc)).toList());
  }
}