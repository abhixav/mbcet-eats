import 'package:flutter/material.dart';
import 'view_orders_screen.dart';
import 'edit_menu_screen.dart'; // ✅ updated name

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin Panel')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ViewOrdersScreen()),
                );
              },
              icon: const Icon(Icons.receipt_long),
              label: const Text('View Orders'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const EditMenuScreen()),
                );
              },
              icon: const Icon(Icons.edit),
              label: const Text('Edit Menu'),
              style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(60)),
            ),
          ],
        ),
      ),
    );
  }
}
