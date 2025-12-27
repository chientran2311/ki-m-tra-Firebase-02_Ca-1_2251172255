import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../repositories/order_repository.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final double _shippingFee = 30000; // 30k như ví dụ đề bài

  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  void _showCheckoutBottomSheet(BuildContext context, CartProvider cart) {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Vui lòng đăng nhập để đặt hàng!")),
      );
      return;
    }

    final addressController = TextEditingController(text: user.address); // Tự điền địa chỉ user
    
    // Mapping hiển thị UI -> Giá trị lưu Database
    // UI hiển thị: "Tiền mặt", "Thẻ tín dụng"...
    // Database lưu: "cash", "card", "bank_transfer" (Theo đề bài trang 2)
    final Map<String, String> paymentOptions = {
      'Tiền mặt (Cash)': 'cash',
      'Thẻ tín dụng (Credit Card)': 'card',
      'Chuyển khoản (Bank Transfer)': 'bank_transfer',
    };
    
    String selectedLabel = paymentOptions.keys.first;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
            left: 20, right: 20, top: 20
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Thông tin đặt hàng", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              
              TextField(
                controller: addressController,
                decoration: const InputDecoration(
                  labelText: 'Địa chỉ giao hàng (Shipping Address)',
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              DropdownButtonFormField<String>(
                value: selectedLabel,
                decoration: const InputDecoration(
                  labelText: 'Phương thức thanh toán',
                  prefixIcon: Icon(Icons.payment),
                  border: OutlineInputBorder(),
                ),
                items: paymentOptions.keys.map((label) => DropdownMenuItem(
                  value: label, 
                  child: Text(label)
                )).toList(),
                onChanged: (val) => selectedLabel = val!,
              ),
              
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                  onPressed: () async {
                    if (addressController.text.isEmpty) {
                      ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(content: Text("Vui lòng nhập địa chỉ!")));
                      return;
                    }
                    Navigator.pop(ctx);
                    
                    // Lấy giá trị thực ("card", "cash"...) để lưu
                    String realPaymentMethod = paymentOptions[selectedLabel]!;
                    
                    await _processOrder(
                      context, 
                      cart, 
                      user.customerId, // Dùng customerId chuẩn
                      addressController.text, 
                      realPaymentMethod
                    );
                  },
                  child: const Text("XÁC NHẬN ĐẶT HÀNG", style: TextStyle(fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _processOrder(
      BuildContext context, 
      CartProvider cart, 
      String customerId, 
      String address, 
      String paymentMethod) async {
    
    // Hiển thị Loading
    showDialog(context: context, barrierDismissible: false, builder: (_) => const Center(child: CircularProgressIndicator()));

    try {
      // Chuẩn bị dữ liệu items
      List<OrderItem> orderItems = cart.items.values.map((item) => OrderItem(
        productId: item.productId,
        productName: item.name,
        quantity: item.quantity,
        price: item.price,
      )).toList();

      // Tạo Model đơn hàng
      // ID đơn hàng sẽ để trống ở đây, Repository sẽ tự sinh ID ngẫu nhiên
      OrderModel newOrder = OrderModel(
        orderId: '', 
        customerId: customerId,
        items: orderItems,
        subtotal: cart.totalAmount,
        shippingFee: _shippingFee,
        total: cart.totalAmount + _shippingFee,
        orderDate: DateTime.now(),
        shippingAddress: address, // Lưu đúng tên trường shippingAddress
        status: 'pending',
        paymentMethod: paymentMethod, // Lưu đúng giá trị "cash", "card"...
        paymentStatus: 'pending',
        notes: '',
      );

      // Gọi Repository
      OrderRepository orderRepo = OrderRepository();
      await orderRepo.createOrder(newOrder);

      // Thành công
      if (!mounted) return;
      Navigator.pop(context); // Tắt loading
      cart.clearCart(); // Xóa giỏ hàng

      showDialog(
        context: context, 
        builder: (_) => AlertDialog(
          title: const Text("Thành công!"),
          content: const Text("Đơn hàng đã được tạo."),
          actions: [
            TextButton(onPressed: () {
               Navigator.pop(context); // Tắt dialog
               Navigator.pop(context); // Về trang chủ
            }, child: const Text("OK"))
          ],
        )
      );

    } catch (e) {
      if (!mounted) return;
      Navigator.pop(context); // Tắt loading
      
      // Hiển thị lỗi chi tiết để debug
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Lỗi Đặt Hàng"),
          content: Text("Chi tiết: ${e.toString()}"), // Hiển thị nguyên văn lỗi
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng"))],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final cartItems = cart.items.values.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Màu nền sáng nhẹ
      appBar: AppBar(
        title: Text('My Cart (${cart.itemCount})', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_horiz, color: Colors.black), onPressed: () {})
        ],
      ),
      body: Column(
        children: [
          // DANH SÁCH SẢN PHẨM
          Expanded(
            child: cartItems.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.shopping_cart_outlined, size: 80, color: Colors.grey),
                        SizedBox(height: 16),
                        Text("Giỏ hàng trống", style: TextStyle(color: Colors.grey, fontSize: 18)),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: cartItems.length,
                    itemBuilder: (context, index) {
                      final item = cartItems[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Row(
                          children: [
                            // Ảnh sản phẩm
                            Container(
                              width: 80, height: 80,
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: item.imageUrl.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(item.imageUrl, fit: BoxFit.cover),
                                    )
                                  : const Icon(Icons.image, color: Colors.grey),
                            ),
                            const SizedBox(width: 16),
                            
                            // Thông tin & Logic tăng giảm
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Expanded(
                                        child: Text(
                                          item.name, 
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          maxLines: 1, overflow: TextOverflow.ellipsis
                                        ),
                                      ),
                                      // Nút xóa
                                      GestureDetector(
                                        onTap: () => cart.removeItem(item.productId),
                                        child: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  const Text("Default Option", style: TextStyle(color: Colors.grey, fontSize: 12)),
                                  const SizedBox(height: 8),
                                  
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        formatCurrency(item.price), 
                                        style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold, fontSize: 16)
                                      ),
                                      
                                      // Bộ điều khiển số lượng (Quantity Control)
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.grey[100],
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          children: [
                                            InkWell(
                                              onTap: () => cart.removeSingleItem(item.productId),
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(Icons.remove, size: 16),
                                              ),
                                            ),
                                            Padding(
                                              padding: const EdgeInsets.symmetric(horizontal: 8),
                                              child: Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                            ),
                                            InkWell(
                                              // Lưu ý: Logic thêm này cần ProductModel gốc, 
                                              // ở đây ta tạm gọi logic add thông qua ID nếu provider hỗ trợ,
                                              // hoặc cần truyền full model. 
                                              // Để đơn giản ta chỉ hiển thị quantity, việc tăng phức tạp hơn ở đây 
                                              // nếu CartItem không chứa full ProductModel.
                                              // Giải pháp: Trong CartProvider nên lưu full ProductModel.
                                              // Tạm thời disable nút + ở list view để tránh lỗi, hoặc bạn cần sửa CartItem chứa ProductModel.
                                              onTap: null, // Tạm disable để tránh crash nếu ko có model
                                              child: const Padding(
                                                padding: EdgeInsets.all(4.0),
                                                child: Icon(Icons.add, size: 16, color: Colors.grey),
                                              ),
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
          ),

          // TỔNG KẾT & CHECKOUT (Bottom Sheet)
          if (cartItems.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
                ],
              ),
              child: SafeArea(
                child: Column(
                  children: [
                    _buildSummaryRow("Subtotal", cart.totalAmount),
                    const SizedBox(height: 12),
                    _buildSummaryRow("Shipping Fee", _shippingFee),
                    const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Divider()),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                        Text(formatCurrency(cart.totalAmount + _shippingFee), 
                             style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24, color: Colors.black)),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          elevation: 0,
                        ),
                        onPressed: () => _showCheckoutBottomSheet(context, cart),
                        child: const Text("Checkout  →", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    )
                  ],
                ),
              ),
            )
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, double value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 14)),
        Text(formatCurrency(value), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }
}