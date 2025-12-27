import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/customer_model.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  
  // Lưu thông tin user hiện tại (giả lập User của Firebase Auth)
  CustomerModel? _currentUser;
  CustomerModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Khởi động app: Kiểm tra xem đã login lần trước chưa
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final String? customerId = prefs.getString('customerId');

    if (customerId != null) {
      // Nếu có ID trong máy, lấy thông tin từ Firestore
      final doc = await _db.collection('customers').doc(customerId).get();
      if (doc.exists) {
        _currentUser = CustomerModel.fromFirestore(doc);
        notifyListeners();
      }
    }
  }

  void setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // ĐĂNG KÝ (Logic mới: Chỉ thao tác Firestore)
  Future<void> register(CustomerModel customerData) async {
    try {
      setLoading(true);
      
      // 1. Kiểm tra email đã tồn tại chưa
      final checkQuery = await _db
          .collection('customers')
          .where('email', isEqualTo: customerData.email)
          .get();

      if (checkQuery.docs.isNotEmpty) {
        throw Exception("Email này đã được đăng ký!");
      }

      // 2. Tạo document mới (Firestore tự sinh ID)
      DocumentReference ref = await _db.collection('customers').add(customerData.toMap());
      
      // 3. Cập nhật lại ID thực tế cho model
      _currentUser = CustomerModel(
        customerId: ref.id,
        email: customerData.email,
        fullName: customerData.fullName,
        phoneNumber: customerData.phoneNumber,
        address: customerData.address,
        city: customerData.city,
        postalCode: customerData.postalCode,
        createdAt: customerData.createdAt,
        isActive: true,
      );

      // 4. Lưu session
      await _saveSession(_currentUser!.customerId);
      
      setLoading(false);
    } catch (e) {
      setLoading(false);
      rethrow;
    }
  }

  // ĐĂNG NHẬP (Logic mới: Query Firestore)
  Future<void> login(String email) async {
    try {
      setLoading(true);
      
      // 1. Tìm user theo email
      final query = await _db
          .collection('customers')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        throw Exception("Email chưa được đăng ký!");
      }

      // 2. Đăng nhập thành công -> Lấy dữ liệu về
      final doc = query.docs.first;
      _currentUser = CustomerModel.fromFirestore(doc);

      // 3. Lưu session vào SharedPreferences (Yêu cầu đề bài)
      await _saveSession(doc.id);

      setLoading(false);
    } catch (e) {
      setLoading(false);
      rethrow;
    }
  }

  // LOGOUT
  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear(); // Xóa session
    _currentUser = null;
    notifyListeners();
  }

  Future<void> _saveSession(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customerId', id);
    await prefs.setBool('is_logged_in', true);
  }
}