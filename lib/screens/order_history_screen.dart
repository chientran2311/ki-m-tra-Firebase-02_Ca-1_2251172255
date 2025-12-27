import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/order_model.dart';
import '../../providers/auth_provider.dart';
import '../../repositories/order_repository.dart';
import 'order_detail_screen.dart'; // Sẽ tạo ngay bên dưới

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  final OrderRepository _orderRepo = OrderRepository();
  String _selectedFilter = 'All Orders';
  final List<String> _filters = ['All Orders', 'Pending', 'Delivered', 'Cancelled'];

  // Format ngày tháng
  String formatDate(DateTime date) {
    return DateFormat('MMM dd, yyyy').format(date);
  }

  // Format tiền tệ
  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  // Helper: Màu sắc theo trạng thái
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'delivered': return Colors.green;
      case 'cancelled': return Colors.red;
      case 'pending': return Colors.orange;
      case 'processing': return Colors.blue;
      case 'shipped': return Colors.purple;
      default: return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).currentUser;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập để xem đơn hàng")));
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        title: const Text('Order History', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.filter_list, color: Colors.blue)),
        ],
      ),
      body: Column(
        children: [
          // 1. FILTER CHIPS
          Container(
            color: Colors.white,
            height: 60,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              scrollDirection: Axis.horizontal,
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final filter = _filters[index];
                final isSelected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  selectedColor: Colors.blue,
                  labelStyle: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  onSelected: (bool selected) {
                    setState(() {
                      _selectedFilter = filter;
                    });
                  },
                );
              },
            ),
          ),

          // 2. ORDER LIST
          Expanded(
            child: StreamBuilder<List<OrderModel>>(
              stream: _orderRepo.getOrdersByCustomer(user.customerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Lỗi: ${snapshot.error}'));
                }

                List<OrderModel> orders = snapshot.data ?? [];

                // Filter logic client-side
                if (_selectedFilter != 'All Orders') {
                  orders = orders.where((o) => o.status.toLowerCase() == _selectedFilter.toLowerCase()).toList();
                }

                if (orders.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(Icons.receipt_long, size: 60, color: Colors.grey),
                        SizedBox(height: 10),
                        Text("Chưa có đơn hàng nào", style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    final statusColor = _getStatusColor(order.status);
                    // Lấy ảnh sp đầu tiên làm thumbnail (giả lập)
                    // Trong thực tế bạn có thể cần fetch ảnh sản phẩm từ productId
                    // Ở đây tôi dùng icon placeholder nếu không load được
                    
                    return GestureDetector(
                      onTap: () {
                         Navigator.push(
                           context, 
                           MaterialPageRoute(builder: (_) => OrderDetailScreen(order: order))
                         );
                      },
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 16),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
                          ],
                        ),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Thumbnail giả lập
                                Container(
                                  width: 60, height: 60,
                                  decoration: BoxDecoration(
                                    color: Colors.grey[100],
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(Icons.shopping_bag, color: Colors.blueGrey), 
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            "Order #${order.orderId.substring(0, 6).toUpperCase()}", // Cắt ngắn ID cho đẹp
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                          ),
                                          Text(
                                            formatDate(order.orderDate),
                                            style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "${order.items.length} items",
                                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                      ),
                                      const SizedBox(height: 8),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          // Status Badge
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: statusColor.withOpacity(0.1),
                                              borderRadius: BorderRadius.circular(20),
                                            ),
                                            child: Text(
                                              order.status.toUpperCase(),
                                              style: TextStyle(
                                                color: statusColor,
                                                fontWeight: FontWeight.bold,
                                                fontSize: 10,
                                              ),
                                            ),
                                          ),
                                          // Price
                                          Text(
                                            formatCurrency(order.total),
                                            style: const TextStyle(
                                              color: Colors.blue,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 12),
                            const Divider(),
                            // Footer Action
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                if (order.status == 'pending')
                                  TextButton(
                                    onPressed: () {
                                       // Nút hủy nhanh ở ngoài list (Optional)
                                    },
                                    child: const Text("Cancel", style: TextStyle(color: Colors.red)),
                                  ),
                                const SizedBox(width: 8),
                                const Text("Details", style: TextStyle(fontSize: 13)),
                                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
                              ],
                            )
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}