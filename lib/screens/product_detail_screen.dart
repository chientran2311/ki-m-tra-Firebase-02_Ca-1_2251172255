import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../models/product_model.dart';
import '../providers/cart_provider.dart';
import 'cart_screen.dart'; // Để navigate đến giỏ hàng từ icon top-right

class ProductDetailScreen extends StatefulWidget {
  final ProductModel product;

  const ProductDetailScreen({super.key, required this.product});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;
  int _selectedColorIndex = 0; // Giả lập chọn màu (UI only)

  // Format tiền tệ
  String formatCurrency(double amount) {
    final formatter = NumberFormat.currency(symbol: '\$', decimalDigits: 0);
    return formatter.format(amount);
  }

  void _addToCart() {
    // Logic: Thêm vào giỏ n lần
    final cart = Provider.of<CartProvider>(context, listen: false);

    // Loop để thêm số lượng (vì hàm addItem của CartProvider hiện tại đang thêm 1 cái/lần)
    // Cách tối ưu hơn là sửa CartProvider có thêm hàm addMultipleItems,
    // nhưng để an toàn với code cũ, ta loop ở đây hoặc gọi addItem nhiều lần.
    // Tạm thời gọi addItem 1 lần và sửa quantity sau, hoặc loop đơn giản.
    for (int i = 0; i < _quantity; i++) {
      cart.addItem(widget.product);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm $_quantity ${widget.product.name} vào giỏ!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isOutOfStock = widget.product.stock <= 0;

    return Scaffold(
      backgroundColor: Colors.white, // Hoặc màu nền của ảnh nếu ảnh có nền
      body: Stack(
        children: [
          // 1. PRODUCT IMAGE (BACKGROUND)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: size.height * 0.45, // Chiếm 45% chiều cao
            child: Container(
              color: const Color(0xFFF1F1F1), // Màu xám nhẹ làm nền ảnh
              child: widget.product.imageUrl.isNotEmpty
                  ? Image.network(widget.product.imageUrl, fit: BoxFit.cover)
                  : const Center(
                      child: Icon(Icons.image, size: 100, color: Colors.grey),
                    ),
            ),
          ),

          // 2. TOP ACTION BAR (Back & Cart)
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 20,
            right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildCircleIconButton(
                  icon: Icons.arrow_back,
                  onTap: () => Navigator.pop(context),
                ),
                Row(
                  children: [
                    _buildCircleIconButton(
                      icon: Icons.favorite_border,
                      onTap: () {},
                    ),
                    const SizedBox(width: 10),
                    // Cart Icon with Badge
                    Consumer<CartProvider>(
                      builder: (context, cart, child) => Stack(
                        children: [
                          _buildCircleIconButton(
                            icon: Icons.shopping_bag_outlined,
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const CartScreen(),
                              ),
                            ),
                          ),
                          if (cart.itemCount > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(4),
                                decoration: const BoxDecoration(
                                  color: Colors.amber,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${cart.itemCount}',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 3. PRODUCT INFO SHEET (Draggable scrollable or Fixed Position)
          Positioned(
            top: size.height * 0.4, // Bắt đầu đè lên ảnh một chút
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(
                24,
                30,
                24,
                100,
              ), // Bottom padding chừa chỗ cho thanh button
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 20,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title & Price
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            widget.product.name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              height: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formatCurrency(widget.product.price),
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            // Giá gốc giả định (cao hơn 10%)
                            Text(
                              formatCurrency(widget.product.price * 1.1),
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.grey,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),

                    // Rating & Stock Status
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "${widget.product.rating} (${widget.product.reviewCount} reviews)",
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.grey,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: isOutOfStock
                                ? Colors.red.withOpacity(0.1)
                                : Colors.green.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.inventory_2,
                                size: 14,
                                color: isOutOfStock ? Colors.red : Colors.green,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isOutOfStock
                                    ? "Hết hàng"
                                    : "Còn lại: ${widget.product.stock}", // HIỂN THỊ SỐ LƯỢNG CỤ THỂ
                                style: TextStyle(
                                  color: isOutOfStock
                                      ? Colors.red
                                      : Colors.green,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Color Selection (UI Mockup)
                    const Text(
                      "Color",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _buildColorOption(Colors.black, 0),
                        _buildColorOption(const Color(0xFFE0E0E0), 1),
                        _buildColorOption(const Color(0xFF1A237E), 2),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Description
                    const Text(
                      "Description",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.product.description.isEmpty
                          ? "Industry-leading noise cancellation optimized to you. The headphones rewrite the rules for distraction-free listening."
                          : widget.product.description,
                      style: TextStyle(color: Colors.grey[600], height: 1.5),
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                    ),
                    GestureDetector(
                      onTap: () {
                        /* Show full description logic */
                      },
                      child: const Text(
                        "Read more",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Feature Cards (Battery, Bluetooth - Static UI)
                    Row(
                      children: [
                        _buildFeatureCard(
                          Icons.battery_charging_full,
                          "Battery Life",
                          "30 Hours",
                        ),
                        const SizedBox(width: 15),
                        _buildFeatureCard(
                          Icons.bluetooth,
                          "Connectivity",
                          "Bluetooth 5.2",
                        ),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // Review Summary (Static UI matching image)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade200),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.product.rating.toString(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: const [
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                  Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 16,
                                  ),
                                ],
                              ),
                              Text(
                                "Based on ${widget.product.reviewCount} reviews",
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 20),
                          // Dummy progress bars
                          Expanded(
                            child: Column(
                              children: [
                                _buildRatingBar(5, 0.8),
                                _buildRatingBar(4, 0.4),
                                _buildRatingBar(3, 0.1),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // 4. BOTTOM FLOATING ACTION BAR
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                top: false,
                child: Row(
                  children: [
                    // Quantity Selector
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.remove, size: 20),
                            onPressed: () {
                              if (_quantity > 1) setState(() => _quantity--);
                            },
                          ),
                          Text(
                            '$_quantity',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.add, size: 20),
                            onPressed: isOutOfStock
                                ? null
                                : () {
                                    // Kiểm tra logic nếu cần: không quá stock
                                    if (_quantity < widget.product.stock) {
                                      setState(() => _quantity++);
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            "Đã đạt giới hạn tồn kho!",
                                          ),
                                        ),
                                      );
                                    }
                                  },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Add to Cart Button
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: isOutOfStock ? null : _addToCart,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text("Add to Cart"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildCircleIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.8), // Kính mờ
          shape: BoxShape.circle,
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)],
        ),
        child: Icon(icon, size: 20, color: Colors.black87),
      ),
    );
  }

  Widget _buildColorOption(Color color, int index) {
    bool isSelected = _selectedColorIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedColorIndex = index),
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(2), // Viền ngoài
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.blue, width: 2) : null,
        ),
        child: Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ),
    );
  }

  Widget _buildFeatureCard(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.blue),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRatingBar(int star, double percent) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Text(
            '$star',
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(2),
              child: LinearProgressIndicator(
                value: percent,
                backgroundColor: Colors.grey[200],
                color: Colors.black87,
                minHeight: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
