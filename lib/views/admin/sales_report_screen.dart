import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SalesReportScreen extends StatelessWidget {
  const SalesReportScreen({super.key});

  Stream<QuerySnapshot> _getTodayOrders() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    return FirebaseFirestore.instance
        .collection('orders')
        .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('timestamp', isLessThan: Timestamp.fromDate(endOfDay))
        .snapshots();
  }

  double _calculateTotalSales(QuerySnapshot snapshot) {
    double total = 0.0;
    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      if (data.containsKey('totalPrice')) {
        total += (data['totalPrice'] as num).toDouble();
      } else if (data.containsKey('items')) {
        final items = List<Map<String, dynamic>>.from(data['items']);
        for (var item in items) {
          final price = (item['price'] ?? 0);
          if (price is num) {
            total += price.toDouble();
          }
        }
      }
    }
    return total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Today's Sales Report")),
      body: StreamBuilder<QuerySnapshot>(
        stream: _getTodayOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No orders placed today.'));
          }

          final orders = snapshot.data!;
          final totalSales = _calculateTotalSales(orders);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Orders: ${orders.docs.length}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Total Sales: ₹${totalSales.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 30),
                const Text(
                  'Order Details',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 10),
                Expanded(
                  child: ListView.builder(
                    itemCount: orders.docs.length,
                    itemBuilder: (context, index) {
                      final data = orders.docs[index].data() as Map<String, dynamic>;
                      final items = List<Map<String, dynamic>>.from(data['items'] ?? []);

                      final validItems = items.where((item) =>
                          item['name'] != null &&
                          item['name'].toString().trim().isNotEmpty &&
                          item['price'] != null &&
                          item['price'] is num);

                      final orderTotal = validItems.fold(0.0, (sum, item) {
                        return sum + (item['price'] as num).toDouble();
                      });

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Order ${index + 1}'),
                          subtitle: validItems.isNotEmpty
                              ? Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: validItems.map((item) {
                                    return Text('${item['name']} - ₹${item['price']}');
                                  }).toList(),
                                )
                              : const Text('No valid items'),
                          trailing: Text(
                            '₹${orderTotal.toStringAsFixed(2)}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
