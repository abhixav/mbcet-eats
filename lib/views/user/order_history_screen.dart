import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../models/order.dart';

class OrderHistoryScreen extends StatelessWidget {
  const OrderHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Orders 📜')),
      body: StreamBuilder<List<UserOrder>>(
        stream: DataService().getOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final orders = snapshot.data ?? [];

          if (orders.isEmpty) {
            return const Center(child: Text("You haven't placed any orders yet."));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final dateTime = order.timestamp?.toLocal();

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 🟢🟠 Status Badge
                      Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: order.status.toLowerCase() == 'completed'
                                ? Colors.green.shade100
                                : Colors.orange.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            order.status.toLowerCase() == 'completed' ? 'Completed' : 'Pending',
                            style: TextStyle(
                              color: order.status.toLowerCase() == 'completed'
                                  ? Colors.green
                                  : Colors.orange,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      if (dateTime != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 8, bottom: 12),
                          child: Text(
                            "${dateTime.day}/${dateTime.month}/${dateTime.year} at ${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')}",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ),

                      const Text("Items:", style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      ...order.items.map((item) => Text("- ${item.name}")),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
