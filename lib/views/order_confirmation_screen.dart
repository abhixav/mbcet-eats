import 'package:flutter/material.dart';

class OrderConfirmationScreen extends StatelessWidget {
  final String token;

  const OrderConfirmationScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(title: const Text("Order Placed")),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, size: 90, color: Colors.green),
              const SizedBox(height: 20),
              const Text(
                "Your order has been placed!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Text(
                "Token Number:",
                style: TextStyle(fontSize: 18, color: Colors.grey.shade800),
              ),
              const SizedBox(height: 8),
              Text(
                token,
                style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.green),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
                icon: const Icon(Icons.home),
                label: const Text("Back to Home"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(50),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
