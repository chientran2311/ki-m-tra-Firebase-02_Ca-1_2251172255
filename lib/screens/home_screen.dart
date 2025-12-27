import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import '../repositories/product_repository.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
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
  int _bottomNavIndex = 0; // Mặc định chọn tab đầu tiên

  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  double? _minPrice;
  double? _maxPrice;

  // Danh mục mẫu
  final List<String> _categories = [
    'All', 'Electronics', 'Clothing', 'Food', 'Books', 'Toys',
  ];

  // Hàm format tiền tệ
  String formatCurrency(double amount) {
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
            left: 20, right: 20, top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Bộ Lọc Sản Phẩm", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              const Text("Danh mục:", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _categories.contains(_selectedCategory) ? _selectedCategory : 'All',
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (val) => setState(() => _selectedCategory = val!),
              ),
              const SizedBox(height: 20),
              const Text("Khoảng giá (\$):", style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _minPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Min", border: OutlineInputBorder()),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text("-"),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _maxPriceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(labelText: "Max", border: OutlineInputBorder()),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
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
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Shop_TranDatChien - 2251172255', 
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 20),
        ),
        actions: [
          Consumer<CartProvider>(
            builder: (context, cart, child) => Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, color: Colors.black),
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
                  },
                ),
                if (cart.itemCount > 0)
                  Positioned(
                    right: 8, top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(color: Colors.blue, borderRadius: BorderRadius.circular(10)),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        '${cart.itemCount}',
                        style: const TextStyle(color: Colors.white, fontSize: 10),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
              ],
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // 1. Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                    child: TextField(
                      onChanged: (value) => setState(() => _searchQuery = value),
                      decoration: const InputDecoration(
                        hintText: 'Search products...',
                        prefixIcon: Icon(Icons.search, color: Colors.grey),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _showFilterDialog,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: (_minPrice != null || _maxPrice != null) ? Colors.blue : Colors.transparent),
                    ),
                    child: Icon(Icons.tune, color: (_minPrice != null || _maxPrice != null) ? Colors.blue : Colors.black),
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
                    onTap: () => setState(() => _selectedCategory = category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.blue : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: isSelected ? null : Border.all(color: Colors.grey.shade300),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(color: isSelected ? Colors.white : Colors.grey.shade800, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 16),

          // 3. Product Grid
          Expanded(
            child: StreamBuilder<List<ProductModel>>(
              stream: _productRepo.getAllProducts(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
                if (snapshot.hasError) return Center(child: Text('Error: ${snapshot.error}'));

                List<ProductModel> products = snapshot.data ?? [];

                // Filter Logic
                if (_selectedCategory != 'All') {
                  products = products.where((p) => p.category == _selectedCategory).toList();
                }
                if (_searchQuery.isNotEmpty) {
                  products = products.where((p) => p.name.toLowerCase().contains(_searchQuery.toLowerCase())).toList();
                }
                if (_minPrice != null) {
                  products = products.where((p) => p.price >= _minPrice!).toList();
                }
                if (_maxPrice != null) {
                  products = products.where((p) => p.price <= _maxPrice!).toList();
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
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.70,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: products.length,
                  itemBuilder: (context, index) => _buildProductCard(products[index]),
                );
              },
            ),
          ),
        ],
      ),

      // --- PHẦN QUAN TRỌNG: CẬP NHẬT BOTTOM NAVIGATION BAR ---
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _bottomNavIndex, 
        // ⚠️ Lưu ý: Nếu app bị crash, hãy Hot Restart để reset _bottomNavIndex về 0
        onTap: (index) {
          setState(() => _bottomNavIndex = index);
          
          // Index 0: Shop (Ở yên đây)
          
          // Index 1: Cart (Giỏ hàng) - Đã đẩy từ 2 xuống 1
          if (index == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const CartScreen()));
          }
          
          // Index 2: History (Lịch sử) - Đã đẩy từ 3 xuống 2
          if (index == 2) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
          }
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: [
          // Item 0
          const BottomNavigationBarItem(
            icon: Icon(Icons.storefront),
            label: 'Shop',
          ),
          
          // Item 1 (Đã bỏ Categories, đẩy Cart lên đây)
          BottomNavigationBarItem(
            icon: Consumer<CartProvider>(
              builder: (context, cart, child) => Stack(
                clipBehavior: Clip.none,
                children: [
                  const Icon(Icons.shopping_bag_outlined),
                  if (cart.itemCount > 0)
                    Positioned(
                      right: -5, top: -5,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                        child: Text('${cart.itemCount}', style: const TextStyle(color: Colors.white, fontSize: 8)),
                      ),
                    )
                ],
              ),
            ),
            label: 'Cart',
          ),
          
          // Item 2 (Đẩy History lên đây)
          const BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'Order History',
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product) {
    bool isOutOfStock = product.stock <= 0;
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProductDetailScreen(product: product))),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, 5))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      color: Colors.grey[100],
                    ),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                      child: Opacity(
                        opacity: isOutOfStock ? 0.5 : 1.0,
                        child: product.imageUrl.isNotEmpty
                            ? Image.network(product.imageUrl, fit: BoxFit.cover, errorBuilder: (c, e, s) => const Icon(Icons.image, size: 50, color: Colors.grey))
                            : const Icon(Icons.image, size: 50, color: Colors.grey),
                      ),
                    ),
                  ),
                  if (isOutOfStock)
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(color: Colors.black.withOpacity(0.7), borderRadius: BorderRadius.circular(4)),
                        child: const Text('OUT OF STOCK', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(product.name, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(formatCurrency(product.price), style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.w900, fontSize: 16)),
                      InkWell(
                        onTap: isOutOfStock ? null : () {
                          Provider.of<CartProvider>(context, listen: false).addItem(product);
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã thêm ${product.name} vào giỏ!'), duration: const Duration(seconds: 1)));
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(color: isOutOfStock ? Colors.grey[300] : Colors.blue[50], shape: BoxShape.circle),
                          child: Icon(isOutOfStock ? Icons.block : Icons.add, color: isOutOfStock ? Colors.grey : Colors.blue, size: 20),
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