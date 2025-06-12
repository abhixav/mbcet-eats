import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // ✅ For timestamp formatting
import '../../services/data_service.dart';
import '../../models/order.dart';

class ViewOrdersScreen extends StatelessWidget {
  const ViewOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Orders")),
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
            return const Center(child: Text('No orders placed yet.'));
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final isCompleted = order.status == 'Completed';

              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('User: ${order.username} | Token: ${order.token}'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ...order.items.map((e) => Text('${e.name} - ₹${e.price}')),
                      const SizedBox(height: 4),
                      Text(
                        'Placed on: ${DateFormat('dd-MM-yyyy hh:mm a').format(order.timestamp)}',
                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Text(
                        'Status: ${order.status}',
                        style: TextStyle(
                          color: isCompleted ? Colors.green : Colors.orange,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: isCompleted
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : ElevatedButton(
                          onPressed: () {
                            DataService().markOrderAsDone(order.id);
                          },
                          child: const Text("Mark Done"),
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
