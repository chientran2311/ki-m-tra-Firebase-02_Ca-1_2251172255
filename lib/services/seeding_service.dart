import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

class SeedingService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Dữ liệu mẫu Products (15 món, đủ category) [cite: 180]
  final List<Map<String, dynamic>> _sampleProducts = [
    // Electronics
    {
      'name': 'Sony WH-1000XM5',
      'description': 'Tai nghe chống ồn hàng đầu thế giới.',
      'price': 348.00,
      'category': 'Electronics',
      'brand': 'Sony',
      'stock': 20,
      'imageUrl': 'https://m.media-amazon.com/images/I/51SKmu2G9FL._AC_UF894,1000_QL80_.jpg',
      'rating': 4.8,
      'reviewCount': 124,
      'isAvailable': true,
    },
    {
      'name': 'Apple Watch SE',
      'description': 'Đồng hồ thông minh giá rẻ từ Apple.',
      'price': 279.00,
      'category': 'Electronics',
      'brand': 'Apple',
      'stock': 15,
      'imageUrl': 'https://store.storeimages.cdn-apple.com/4982/as-images.apple.com/is/watch-card-40-se-202309?wid=340&hei=264&fmt=p-jpg&qlt=95&.v=1693543113465',
      'rating': 4.7,
      'reviewCount': 89,
      'isAvailable': true,
    },
    {
      'name': 'Samsung Galaxy S23',
      'description': 'Điện thoại Android cao cấp.',
      'price': 799.00,
      'category': 'Electronics',
      'brand': 'Samsung',
      'stock': 10,
      'imageUrl': 'https://images.samsung.com/is/image/samsung/p6pim/vn/2302/gallery/vn-galaxy-s23-s911-sm-s911bzegxxv-534863333?650_519_PNG',
      'rating': 4.6,
      'reviewCount': 200,
      'isAvailable': true,
    },
    // Clothing
    {
      'name': 'Nike Air Zoom Pegasus',
      'description': 'Giày chạy bộ chuyên nghiệp.',
      'price': 120.00,
      'category': 'Clothing',
      'brand': 'Nike',
      'stock': 50,
      'imageUrl': 'https://static.nike.com/a/images/t_PDP_1280_v1/f_auto,q_auto:eco/5c370252-875f-4d92-9114-11867154d89e/air-zoom-pegasus-39-road-running-shoes-d4dvtm.png',
      'rating': 4.5,
      'reviewCount': 50,
      'isAvailable': true,
    },
    {
      'name': 'Adidas Hoodie',
      'description': 'Áo khoác thể thao mùa đông.',
      'price': 60.00,
      'category': 'Clothing',
      'brand': 'Adidas',
      'stock': 30,
      'imageUrl': 'https://assets.adidas.com/images/w_600,f_auto,q_auto/8863f637703e48109d93afc700e30129_9366/Ao_Hoodie_Adicolor_Classics_Trefoil_DJen_IM4495_21_model.jpg',
      'rating': 4.2,
      'reviewCount': 35,
      'isAvailable': true,
    },
    {
      'name': 'Levi\'s 501 Original',
      'description': 'Quần Jean cổ điển.',
      'price': 98.00,
      'category': 'Clothing',
      'brand': 'Levi\'s',
      'stock': 40,
      'imageUrl': 'https://lsco.scene7.com/is/image/lsco/005010193-front-pdp?fmt=jpeg&qlt=70&resMode=bisharp&fit=crop,0&op_usm=1.25,0.6,8&wid=2000&hei=1800',
      'rating': 4.4,
      'reviewCount': 110,
      'isAvailable': true,
    },
    // Books
    {
      'name': 'Clean Code',
      'description': 'Sách gối đầu giường cho Developer.',
      'price': 45.00,
      'category': 'Books',
      'brand': 'Prentice Hall',
      'stock': 25,
      'imageUrl': 'https://m.media-amazon.com/images/I/41xShlnTZTL._SX218_BO1,204,203,200_QL40_FMwebp_.jpg',
      'rating': 4.9,
      'reviewCount': 500,
      'isAvailable': true,
    },
    {
      'name': 'Flutter Apprentice',
      'description': 'Học Flutter từ cơ bản đến nâng cao.',
      'price': 55.00,
      'category': 'Books',
      'brand': 'Kodeco',
      'stock': 12,
      'imageUrl': 'https://assets.kodeco.com/books/flta/cover-v2-social.png',
      'rating': 4.8,
      'reviewCount': 80,
      'isAvailable': true,
    },
    {
      'name': 'The Great Gatsby',
      'description': 'Tiểu thuyết kinh điển.',
      'price': 15.00,
      'category': 'Books',
      'brand': 'Scribner',
      'stock': 60,
      'imageUrl': 'https://upload.wikimedia.org/wikipedia/commons/7/7a/The_Great_Gatsby_Cover_1925_Retouched.jpg',
      'rating': 4.3,
      'reviewCount': 300,
      'isAvailable': true,
    },
    // Food
    {
      'name': 'Organic Coffee Beans',
      'description': 'Cà phê nguyên chất 1kg.',
      'price': 25.00,
      'category': 'Food',
      'brand': 'Trung Nguyen',
      'stock': 100,
      'imageUrl': 'https://trungnguyenlegend.com/wp-content/uploads/2021/04/sang-tao-1-600x600.jpg',
      'rating': 4.6,
      'reviewCount': 150,
      'isAvailable': true,
    },
    {
      'name': 'Chocolate Box',
      'description': 'Hộp socola Valentine.',
      'price': 30.00,
      'category': 'Food',
      'brand': 'Lindt',
      'stock': 5,
      'imageUrl': 'https://www.lindt.co.uk/media/catalog/product/c/l/classic_collection_box.jpg',
      'rating': 4.7,
      'reviewCount': 90,
      'isAvailable': true,
    },
    {
      'name': 'Green Tea Box',
      'description': 'Trà xanh Nhật Bản.',
      'price': 12.00,
      'category': 'Food',
      'brand': 'Cozy',
      'stock': 80,
      'imageUrl': 'https://bizweb.dktcdn.net/thumb/1024x1024/100/364/483/products/tra-xanh-cozy-25-goi-2g-1.jpg',
      'rating': 4.1,
      'reviewCount': 40,
      'isAvailable': true,
    },
    // Toys
    {
      'name': 'Lego Star Wars',
      'description': 'Bộ lắp ráp tàu vũ trụ.',
      'price': 150.00,
      'category': 'Toys',
      'brand': 'Lego',
      'stock': 8,
      'imageUrl': 'https://www.lego.com/cdn/cs/set/assets/blt5b426054f8546b45/75192.jpg',
      'rating': 4.9,
      'reviewCount': 60,
      'isAvailable': true,
    },
    {
      'name': 'Barbie Doll',
      'description': 'Búp bê Barbie thời trang.',
      'price': 25.00,
      'category': 'Toys',
      'brand': 'Mattel',
      'stock': 45,
      'imageUrl': 'https://shop.mattel.com/cdn/shop/products/HGM56_Barbie_60th_Celebration_Doll_Shot_08.jpg',
      'rating': 4.4,
      'reviewCount': 110,
      'isAvailable': true,
    },
    {
      'name': 'Hot Wheels Set',
      'description': 'Bộ sưu tập xe đua.',
      'price': 20.00,
      'category': 'Toys',
      'brand': 'Hot Wheels',
      'stock': 70,
      'imageUrl': 'https://m.media-amazon.com/images/I/81+Xp-K9tLL.jpg',
      'rating': 4.5,
      'reviewCount': 130,
      'isAvailable': true,
    },
  ];

  Future<void> seedData() async {
    try {
      // 1. Tạo 5 Customers [cite: 172]
      List<String> customerIds = [];
      for (int i = 1; i <= 5; i++) {
        DocumentReference ref = await _db.collection('customers').add({
          'email': 'customer$i@example.com',
          'fullName': 'Customer $i Sample',
          'phoneNumber': '090123456$i',
          'address': '$i Le Loi Street',
          'city': 'Ho Chi Minh',
          'postalCode': '70000',
          'createdAt': FieldValue.serverTimestamp(),
          'isActive': true,
        });
        customerIds.add(ref.id);
      }
      print("✅ Created 5 customers");

      // 2. Tạo 15 Products [cite: 180]
      List<Map<String, dynamic>> createdProducts = [];
      for (var p in _sampleProducts) {
        DocumentReference ref = await _db.collection('products').add({
          ...p,
          'createdAt': FieldValue.serverTimestamp(),
        });
        // Lưu lại ID và thông tin để dùng tạo Order
        createdProducts.add({
          'id': ref.id,
          'name': p['name'],
          'price': p['price'],
        });
      }
      print("✅ Created 15 products");

      // 3. Tạo 8 Orders [cite: 181]
      final random = Random();
      final statuses = ['pending', 'confirmed', 'processing', 'shipped', 'delivered', 'cancelled'];
      final paymentMethods = ['cash', 'card', 'bank_transfer'];

      for (int i = 1; i <= 8; i++) {
        String customerId = customerIds[random.nextInt(customerIds.length)];
        
        // Random 1-3 sản phẩm cho mỗi đơn
        int itemCount = random.nextInt(3) + 1;
        List<Map<String, dynamic>> orderItems = [];
        double subtotal = 0;

        for (int j = 0; j < itemCount; j++) {
          var prod = createdProducts[random.nextInt(createdProducts.length)];
          int quantity = random.nextInt(2) + 1;
          double price = prod['price'];
          
          orderItems.add({
            'productId': prod['id'],
            'productName': prod['name'],
            'quantity': quantity,
            'price': price,
          });
          subtotal += price * quantity;
        }

        double shippingFee = 30000; // 30k vnd ~ 1.2 USD, lấy mẫu đề bài
        
        await _db.collection('orders').add({
          'customerId': customerId,
          'items': orderItems,
          'subtotal': subtotal,
          'shippingFee': shippingFee,
          'total': subtotal + shippingFee,
          'orderDate': FieldValue.serverTimestamp(),
          'shippingAddress': '$i Nguyen Hue Street, HCM',
          'status': statuses[random.nextInt(statuses.length)],
          'paymentMethod': paymentMethods[random.nextInt(paymentMethods.length)],
          'paymentStatus': 'paid',
          'notes': 'Giao hang nhanh',
        });
      }
      print("✅ Created 8 orders");

    } catch (e) {
      print("❌ Error seeding data: $e");
      rethrow;
    }
  }
}