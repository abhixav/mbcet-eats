import 'dart:convert';
import 'dart:html' as html;
import 'package:csv/csv.dart';
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
      final items = List<Map<String, dynamic>>.from(data['items']);
      for (var item in items) {
        final price = (item['price'] ?? 0).toDouble();
        total += price;
      }
    }
    return total;
  }

  void _downloadCSVWeb(QuerySnapshot snapshot) {
    List<List<String>> rows = [
      ['Order No.', 'Items', 'Total Price']
    ];

    int orderNo = 1;
    double totalSales = 0.0;

    for (var doc in snapshot.docs) {
      final data = doc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(data['items']);

      final itemNames = items.map((item) => item['name'].toString()).join(', ');
      final orderTotal = items.fold(0.0, (sum, item) => sum + (item['price'] ?? 0).toDouble());

      rows.add([
        'Order $orderNo',
        itemNames,
        orderTotal.toStringAsFixed(2),
      ]);

      totalSales += orderTotal;
      orderNo++;
    }

    rows.add([]);
    rows.add(['', 'Total Sales', totalSales.toStringAsFixed(2)]);

    final csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "sales_report.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Today's Sales Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final snapshot = await FirebaseFirestore.instance
                  .collection('orders')
                  .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(
                      DateTime.now().subtract(const Duration(hours: 24))))
                  .get();

              _downloadCSVWeb(snapshot);
            },
          )
        ],
      ),
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
                      final orderTotal = items.fold(0.0, (sum, item) {
                        final price = (item['price'] ?? 0).toDouble();
                        return sum + price;
                      });

                      return Card(
                        elevation: 3,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Order ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: items
                                .where((item) => item['name'] != null && item['price'] != null)
                                .map((item) => Text('${item['name']} - ₹${item['price']}'))
                                .toList(),
                          ),
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
