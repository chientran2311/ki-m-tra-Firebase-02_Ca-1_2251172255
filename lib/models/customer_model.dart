import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerModel {
  final String customerId;
  final String email;
  final String fullName;
  final String phoneNumber;
  final String address;
  final String city;
  final String postalCode;
  final DateTime createdAt;
  final bool isActive;

  CustomerModel({
    required this.customerId,
    required this.email,
    required this.fullName,
    required this.phoneNumber,
    required this.address,
    required this.city,
    required this.postalCode,
    required this.createdAt,
    required this.isActive,
  });

  // Chuyển từ Firestore Document -> Object
  factory CustomerModel.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return CustomerModel(
      customerId: doc.id,
      email: data['email'] ?? '',
      fullName: data['fullName'] ?? '',
      phoneNumber: data['phoneNumber'] ?? '',
      address: data['address'] ?? '',
      city: data['city'] ?? '',
      postalCode: data['postalCode'] ?? '',
      // Xử lý an toàn cho Timestamp
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isActive: data['isActive'] ?? true,
    );
  }

  // Chuyển từ Object -> Map (để lưu lên Firestore)
  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'city': city,
      'postalCode': postalCode,
      'createdAt': Timestamp.fromDate(createdAt),
      'isActive': isActive,
    };
  }
}