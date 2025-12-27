import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';

class OrderDetailScreen extends StatelessWidget {
  final OrderModel order;
  
  const OrderDetailScreen({super.key, required this.order});

  // Format tiền tệ
  String formatCurrency(double amount) {
    return NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(amount);
  }

  // Xử lý hủy đơn
  void _cancelOrder(BuildContext context) async {
    // Show confirm dialog
    bool? confirm = await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Hủy Đơn Hàng?"),
        content: const Text("Bạn có chắc chắn muốn hủy đơn hàng này không?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text("Không")),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text("Có, Hủy đơn", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await OrderRepository().updateOrderStatus(order.orderId, 'cancelled');
        if (!context.mounted) return;
        Navigator.pop(context); // Quay lại màn hình history
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đã hủy đơn hàng thành công!")),
        );
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Lỗi: $e")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Order Details")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Header Info
            Text("Order ID: ${order.orderId}", style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("Date: ${DateFormat('yyyy-MM-dd HH:mm').format(order.orderDate)}"),
            Text("Status: ${order.status.toUpperCase()}", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            const Divider(height: 30),

            // 2. List Items
            const Text("Items:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...order.items.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  Container(
                    width: 50, height: 50, color: Colors.grey[200],
                    child: const Icon(Icons.image),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item.productName, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text("x${item.quantity}"),
                      ],
                    ),
                  ),
                  Text(formatCurrency(item.price * item.quantity)),
                ],
              ),
            )).toList(),
            
            const Divider(height: 30),

            // 3. Payment Info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Shipping Fee"),
                Text(formatCurrency(order.shippingFee)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(formatCurrency(order.total), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
              ],
            ),

            const SizedBox(height: 10),
            Text("Address: ${order.shippingAddress}", style: const TextStyle(color: Colors.grey)),
            Text("Payment: ${order.paymentMethod}", style: const TextStyle(color: Colors.grey)),

            const SizedBox(height: 40),

            // 4. Cancel Button (Chỉ hiện nếu status là Pending)
            if (order.status == 'pending')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () => _cancelOrder(context),
                  child: const Text("CANCEL ORDER"),
                ),
              )
          ],
        ),
      ),
    );
  }
}