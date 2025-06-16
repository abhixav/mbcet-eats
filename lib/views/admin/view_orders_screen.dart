import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../services/data_service.dart';
import '../../models/order.dart';
import '../../constants/colors.dart';

class ViewOrdersScreen extends StatelessWidget {
  const ViewOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Admin - View Orders"),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: StreamBuilder<List<UserOrder>>(
        stream: DataService().getAllOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Center(child: Text('❌ Error loading orders.'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = snapshot.data!;
          if (orders.isEmpty) {
            return const Center(child: Text('🛒 No orders placed yet.'));
          }

          // Group orders by scheduled delivery date
          final Map<String, List<UserOrder>> groupedOrders = {};
          for (var order in orders) {
            final dateKey = DateFormat('dd MMM yyyy').format(order.scheduledFor);
            groupedOrders.putIfAbsent(dateKey, () => []).add(order);
          }

          return ListView(
            padding: const EdgeInsets.all(12),
            children: groupedOrders.entries.map((entry) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Text(
                      "📅 Delivery Date: ${entry.key}",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  ...entry.value.map((order) {
                    final isCompleted = order.status == 'Completed';

                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Top row: Username & token
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  _formatName(order.username),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AppColors.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    "Token #${order.token}",
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 8),

                            // Items
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: order.items.map((item) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 2),
                                  child: Text(
                                    "• ${item.name} - ₹${item.price}",
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                );
                              }).toList(),
                            ),

                            const SizedBox(height: 10),

                            // Timestamp and status
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  "Placed: ${DateFormat('hh:mm a').format(order.timestamp)}",
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isCompleted
                                        ? Colors.green.withOpacity(0.1)
                                        : Colors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    order.status,
                                    style: TextStyle(
                                      color: isCompleted
                                          ? Colors.green
                                          : Colors.orange,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 10),

                            // Mark Done button
                            if (!isCompleted)
                              Align(
                                alignment: Alignment.bottomRight,
                                child: ElevatedButton.icon(
                                  onPressed: () {
                                    DataService().markOrderAsDone(order.id);
                                  },
                                  icon: const Icon(Icons.check, size: 18),
                                  label: const Text("Mark Done"),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 14, vertical: 8),
                                    textStyle: const TextStyle(fontSize: 14),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ],
              );
            }).toList(),
          );
        },
      ),
    );
  }

  String _formatName(String username) {
    final parts = username.trim().split(' ');
    if (parts.length >= 2) {
      return '${_capitalize(parts[0])} ${_capitalize(parts[1])}';
    }
    return _capitalize(parts[0]);
  }

  String _capitalize(String s) {
    if (s.isEmpty) return s;
    return s[0].toUpperCase() + s.substring(1).toLowerCase();
  }
}
