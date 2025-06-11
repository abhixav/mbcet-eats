import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../services/data_service.dart';
import '../order_confirmation_screen.dart';

class CheckoutScreen extends StatelessWidget {
  final Map<MenuItem, int> cart;
  final String userId;

  const CheckoutScreen({super.key, required this.cart, required this.userId});

  @override
  Widget build(BuildContext context) {
    final items = cart.entries.toList();
    final total = items.fold(0, (sum, item) => sum + (item.key.price * item.value));

    return Scaffold(
      appBar: AppBar(title: const Text("Checkout")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text(
              "Your Cart",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.separated(
                itemCount: items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ListTile(
                    leading: CircleAvatar(
                      child: Text("${item.value}x"),
                      backgroundColor: Colors.teal.shade100,
                    ),
                    title: Text(item.key.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text("₹${item.key.price} x ${item.value}"),
                    trailing: Text("₹${item.key.price * item.value}"),
                  );
                },
              ),
            ),
            const Divider(thickness: 2),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹$total", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                final token = await DataService().placeOrder(
                  userId,
                  cart.entries.expand((e) => List.filled(e.value, e.key)).toList(),
                );
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => OrderConfirmationScreen(token: token.toString()),
                  ),
                );
              },
              icon: const Icon(Icons.check_circle),
              label: const Text("Place Order"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
              ),
            )
          ],
        ),
      ),
    );
  }
}
