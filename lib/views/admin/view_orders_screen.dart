import 'package:flutter/material.dart';
import '../../services/data_service.dart';
import '../../models/order.dart';

class ViewOrdersScreen extends StatelessWidget {
  const ViewOrdersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("View Orders")),
      body: StreamBuilder<List<UserOrder>>(
        stream: DataService().getOrders(),
        builder: (context, snapshot) {
          if (snapshot.hasError) return const Center(child: Text('Error loading orders.'));
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

          final orders = snapshot.data!;
          if (orders.isEmpty) return const Center(child: Text('No orders placed yet.'));

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return Card(
                margin: const EdgeInsets.all(8),
                child: ListTile(
                  title: Text('User: ${order.username} | Token: ${order.token}'),
                  subtitle: Text(order.items.map((e) => e.name).join(', ')),
                  trailing: ElevatedButton(
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
