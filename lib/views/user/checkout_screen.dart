import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../services/data_service.dart';
import '../order_confirmation_screen.dart';
import '../../constants/colors.dart';
import 'dart:async';

class CheckoutScreen extends StatefulWidget {
  final Map<MenuItem, int> cart;
  final String userId;

  const CheckoutScreen({super.key, required this.cart, required this.userId});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  late Map<MenuItem, int> cart;
  DateTime _scheduledDate = DateTime.now(); // 🆕 Default to today

  @override
  void initState() {
    super.initState();
    cart = Map.from(widget.cart);
  }

  void _increaseQty(MenuItem item) {
    setState(() {
      cart[item] = (cart[item] ?? 1) + 1;
    });
  }

  void _decreaseQty(MenuItem item) {
    setState(() {
      if ((cart[item] ?? 1) > 1) {
        cart[item] = cart[item]! - 1;
      } else {
        cart.remove(item);
      }
    });
  }

  double get total {
    return cart.entries.fold(0, (sum, item) => sum + (item.key.price * item.value));
  }

  Future<void> _pickDate(BuildContext context) async {
    final selected = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 7)),
    );

    if (selected != null) {
      setState(() => _scheduledDate = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = cart.entries.toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text("Checkout", style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text("Your Cart", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),

            // 🆕 Schedule Order Section
            Row(
              children: [
                const Icon(Icons.calendar_month, color: Colors.teal),
                const SizedBox(width: 8),
                const Text("Scheduled for:"),
                const SizedBox(width: 8),
                Text(
                  "${_scheduledDate.toLocal()}".split(' ')[0],
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () => _pickDate(context),
                  child: const Text("Change Date"),
                ),
              ],
            ),
            const SizedBox(height: 12),

            if (items.isEmpty)
              const Expanded(
                child: Center(
                  child: Text("Your cart is empty.", style: TextStyle(fontSize: 18, color: Colors.grey)),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: items.length,
                  itemBuilder: (context, index) {
                    final entry = items[index];
                    return Card(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 22,
                              backgroundColor: Colors.teal.shade100,
                              child: Text("${entry.value}x", style: const TextStyle(color: AppColors.primary)),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(entry.key.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                                  const SizedBox(height: 4),
                                  Text("₹${entry.key.price} each", style: const TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.remove_circle_outline),
                                  color: AppColors.primary,
                                  onPressed: () => _decreaseQty(entry.key),
                                ),
                                Text('${entry.value}', style: const TextStyle(fontSize: 16)),
                                IconButton(
                                  icon: const Icon(Icons.add_circle_outline),
                                  color: AppColors.primary,
                                  onPressed: () => _increaseQty(entry.key),
                                ),
                              ],
                            ),
                            const SizedBox(width: 8),
                            Text(
                              "₹${entry.key.price * entry.value}",
                              style: const TextStyle(fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

            const Divider(thickness: 1.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Total", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Text("₹${total.toStringAsFixed(2)}", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: cart.isEmpty
                  ? null
                  : () async {
                      try {
                        final token = await DataService().placeOrder(cart, scheduledDate: _scheduledDate); // 🆕
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => OrderConfirmationScreen(token: token.toString()),
                          ),
                        );
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("❌ Failed to place order: $e"),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
              icon: const Icon(Icons.check_circle),
              label: const Text("Place Order"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
