import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Để format tiền tệ (cần thêm intl vào pubspec nếu chưa có, hoặc dùng hàm tự viết)

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../repositories/product_repository.dart';
import 'cart_screen.dart'; // Sẽ tạo ở bước sau
import 'product_detail_screen.dart'; // Sẽ tạo ở bước sau
import 'order_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ProductRepository _productRepo = ProductRepository();
  String _searchQuery = '';
  String _selectedCategory = 'All';
  int _bottomNavIndex = 0;
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  double? _minPrice;
  double? _maxPrice;
  // Danh mục mẫu (khớp với dữ liệu Firestore của bạn)
  final List<String> _categories = [
    'All',
    'Electronics',
    'Clothing',
    'Food',
    'Books',
    'Toys',
  ];

  // Hàm format tiền tệ
  String formatCurrency(double amount) {
    // Nếu chưa có intl, dùng tạm: return "\$${amount.toStringAsFixed(2)}";
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 2);
    return formatter.format(amount);
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Bộ Lọc Sản Phẩm",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // 1. Dropdown Category
              const Text(
                "Danh mục:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedCategory,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (val) {
                  setState(() => _selectedCategory = val!);
                },
              ),

              const SizedBox(height: 20),

              // 2. Price Range (Min - Max)
              const Text(
                "Khoảng giá (\$):",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Min",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("-"),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: "Max",
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 3. Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        // Reset filter
                        setState(() {
                          _selectedCategory = 'All';
                          _minPriceController.clear();
                          _maxPriceController.clear();
                          _minPrice = null;
                          _maxPrice = null;
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text("Xóa lọc"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Apply filter
                        setState(() {
                          _minPrice = double.tryParse(_minPriceController.text);
                          _maxPrice = double.tryParse(_maxPriceController.text);
                        });
                        Navigator.pop(ctx);
                      },
                      child: const Text("Áp dụng"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5), // Màu nền xám nhẹ như thiết kế
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Shop_TranDatChien - 2251172255', // THAY MÃ SINH VIÊN CỦA BẠN VÀO ĐÂY
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        actions: [
          // Icon Giỏ hàng với Badge số lượng
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              children: [
                IconButton(
                  icon: const Icon(
                    Icons.shopping_cart_outlined,
                    color: Colors.black,
                  ),
                  onPressed: () {
                    // Chuyển sang màn hình giỏ hàng
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const CartScreen()),
                    );
                  },
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar & Filter Button
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: TextField(
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showFilterDialog, // <--- GỌI HÀM Ở ĐÂY
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: (_minPrice != null || _maxPrice != null)
                            ? Colors.blue
                            : Colors.transparent,
                      ), // Hiển thị viền nếu đang lọc
                    ),
                    child: Icon(
                      Icons.tune,
                      color: (_minPrice != null || _maxPrice != null)
                          ? Colors.blue
                          : Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 2. Category Chips
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = _selectedCategory == category;
                return Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected
                            ? null
                            : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : Colors.grey.shade800,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 3. Product Grid (StreamBuilder)
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _productRepo.getAllProducts(), // Lắng nghe realtime
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                List<ProductModel> products = snapshot.data ?? [];

                // Client-side Filtering (Lọc dữ liệu tại máy)
                // 1. Lọc theo Category
                if (_selectedCategory != 'All') {
                  products = products
                      .where((p) => p.category == _selectedCategory)
                      .toList();
                }
                // 2. Lọc theo Search Query
                if (_searchQuery.isNotEmpty) {
                  products = products
                      .where(
                        (p) => p.name.toLowerCase().contains(
                          _searchQuery.toLowerCase(),
                        ),
                      )
                      .toList();
                }
                if (_minPrice != null) {
                  products = products
                      .where((p) => p.price >= _minPrice!)
                      .toList();
                }
                if (_maxPrice != null) {
                  products = products
                      .where((p) => p.price <= _maxPrice!)
                      .toList();
                }
                if (products.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.search_off, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text('Không tìm thấy sản phẩm nào'),
                      ],
                    ),
                  );
                }

                return GridView.builder(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2, // 2 cột
                    childAspectRatio: 0.70, // Tỷ lệ khung hình (cao hơn rộng)
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) {
                    final product = products[index];
                    return _buildProductCard(product);
                  },
                );
              },
            ),
          ),
        ],
      ),

      // Bottom Navigation Bar giả lập giống thiết kế
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex,
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CartScreen()),
            );
          }
          // THÊM ĐOẠN NÀY:
          if (index == 3) {
            // Giả sử icon Profile là icon thứ 4
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const OrderHistoryScreen()),
            );
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              // Badge ở bottom nav nếu cần
              builder: (context, cart, child) => Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_bag_outlined),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: -5,
                      top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '${cart.itemCount}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            label: 'Cart',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  // Widget hiển thị từng thẻ sản phẩm
  Widget _buildProductCard(ProductModel product) {
    bool isOutOfStock = product.stock <= 0;

    return GestureDetector(
      onTap: () {
        // Chuyển sang chi tiết
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh sản phẩm + Badges
            Expanded(
              child: Stack(
                children: [
                  // Ảnh nền
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      color: Colors.grey[100], // Placeholder color
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                      child: Opacity(
                        opacity: isOutOfStock
                            ? 0.5
                            : 1.0, // Làm mờ nếu hết hàng
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(
                                product.imageUrl,
                                fit: BoxFit.cover,
                                errorBuilder: (c, e, s) => const Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: Colors.grey,
                                ),
                              )
                            : const Icon(
                                Icons.image,
                                size: 50,
                                color: Colors.grey,
                              ),
                      ),
                    ),
                  ),

                  // Nút Favorite (Góc phải trên)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite_border,
                        size: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ),

                  // Badge "OUT OF STOCK"
                  if (isOutOfStock)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'OUT OF STOCK',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),

                  // Badge "NEW" (Ví dụ logic: sp mới tạo trong 3 ngày)
                  if (!isOutOfStock &&
                      DateTime.now().difference(product.createdAt).inDays < 3)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.amber,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'NEW',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Thông tin sản phẩm
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: Colors.amber, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        product.rating.toString(),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),

                  // Tên sản phẩm
                  Text(
                    product.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Giá và nút Add
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        formatCurrency(product.price),
                        style: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                        ),
                      ),
                      InkWell(
                        onTap: isOutOfStock
                            ? null
                            : () {
                                // Logic thêm vào giỏ hàng
                                Provider.of<CartProvider>(
                                  context,
                                  listen: false,
                                ).addItem(product);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Đã thêm ${product.name} vào giỏ!',
                                    ),
                                    duration: const Duration(seconds: 1),
                                    behavior: SnackBarBehavior.floating,
                                  ),
                                );
                              },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? Colors.grey[300]
                                : Colors.blue[50],
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            isOutOfStock ? Icons.block : Icons.add,
                            color: isOutOfStock ? Colors.grey : Colors.blue,
                            size: 20,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
