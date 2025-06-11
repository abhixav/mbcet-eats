import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../services/data_service.dart';
import 'checkout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Map<String, int> _cart = {};
  final Map<String, MenuItem> _menuLookup = {};
  final ValueNotifier<int> _cartNotifier = ValueNotifier<int>(0);

  void _addToCart(MenuItem item) {
    _menuLookup[item.name] = item;
    _cart[item.name] = (_cart[item.name] ?? 0) + 1;
    _cartNotifier.value++; // Notify UI to refresh cart count
  }

  void _goToCheckout() {
    final cartItems = <MenuItem, int>{};
    for (var entry in _cart.entries) {
      final item = _menuLookup[entry.key];
      if (item != null) {
        cartItems[item] = entry.value;
      }
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CheckoutScreen(cart: cartItems),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('MBCET Eats 🍱')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Today\'s Menu',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          ),
          Expanded(
            child: StreamBuilder<List<MenuItem>>(
              stream: DataService().getMenuItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(
                      child: Text("Error: ${snapshot.error}",
                          style: TextStyle(color: Colors.red)));
                }

                final menuItems = snapshot.data ?? [];

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuItems[index];
                    _menuLookup[item.name] = item;

                    return ValueListenableBuilder<int>(
                      valueListenable: _cartNotifier,
                      builder: (_, __, ___) {
                        final count = _cart[item.name] ?? 0;

                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.name,
                                        style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(height: 5),
                                    Text("₹${item.price}",
                                        style: const TextStyle(color: Colors.grey)),
                                  ],
                                ),
                                ElevatedButton.icon(
                                  onPressed: () => _addToCart(item),
                                  icon: const Icon(Icons.add),
                                  label:
                                      Text(count == 0 ? 'Add' : 'Add ($count)'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.teal,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10)),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
          ValueListenableBuilder<int>(
            valueListenable: _cartNotifier,
            builder: (_, __, ___) {
              return _cart.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: ElevatedButton.icon(
                        onPressed: _goToCheckout,
                        icon: const Icon(Icons.shopping_cart),
                        label: const Text('Proceed to Checkout'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal.shade700,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                    )
                  : const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }
}
