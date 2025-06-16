import 'dart:convert';
import 'dart:html' as html;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class SalesReportScreen extends StatefulWidget {
  const SalesReportScreen({super.key});

  @override
  State<SalesReportScreen> createState() => _SalesReportScreenState();
}

class _SalesReportScreenState extends State<SalesReportScreen> {
  DateTime? _selectedDate;
  DateTimeRange? _selectedDateRange;
  String? _selectedMonth;

  final List<String> _months = List.generate(
    12,
    (index) => DateFormat('MM-yyyy').format(DateTime(DateTime.now().year, index + 1)),
  );

  Future<List<QueryDocumentSnapshot>> _getFilteredOrders() async {
    final now = DateTime.now();
    DateTime start;
    DateTime end;

    if (_selectedDate != null) {
      start = DateTime(_selectedDate!.year, _selectedDate!.month, _selectedDate!.day);
      end = start.add(const Duration(days: 1));
    } else if (_selectedDateRange != null) {
      start = DateTime(_selectedDateRange!.start.year, _selectedDateRange!.start.month, _selectedDateRange!.start.day);
      end = DateTime(_selectedDateRange!.end.year, _selectedDateRange!.end.month, _selectedDateRange!.end.day)
          .add(const Duration(days: 1));
    } else if (_selectedMonth != null) {
      final parts = _selectedMonth!.split('-');
      final month = int.parse(parts[0]);
      final year = int.parse(parts[1]);
      start = DateTime(year, month);
      end = DateTime(year, month + 1);
    } else {
      start = DateTime(now.year, now.month, now.day);
      end = start.add(const Duration(days: 1));
    }

    final snapshot = await FirebaseFirestore.instance.collection('orders').get();

    final filtered = snapshot.docs.where((doc) {
      final data = doc.data();
      final timestamp = (data['scheduledFor'] ?? data['timestamp']) as Timestamp?;
      if (timestamp == null) return false;
      final date = timestamp.toDate();
      return date.isAfter(start.subtract(const Duration(seconds: 1))) &&
          date.isBefore(end);
    }).toList();

    filtered.sort((a, b) {
      final aDate = ((a.data()['scheduledFor'] ?? a.data()['timestamp']) as Timestamp).toDate();
      final bDate = ((b.data()['scheduledFor'] ?? b.data()['timestamp']) as Timestamp).toDate();
      return bDate.compareTo(aDate);
    });

    return filtered;
  }

  double _calculateTotalSales(List<QueryDocumentSnapshot> docs) {
    double total = 0.0;
    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(data['items']);
      for (var item in items) {
        total += (item['price'] ?? 0).toDouble();
      }
    }
    return total;
  }

  void _downloadCSV(List<QueryDocumentSnapshot> docs) {
    List<List<String>> rows = [
      ['Order No.', 'Delivery Date', 'Items', 'Total Price']
    ];

    int orderNo = 1;
    double totalSales = 0.0;

    for (var doc in docs) {
      final data = doc.data() as Map<String, dynamic>;
      final items = List<Map<String, dynamic>>.from(data['items']);
      final itemNames = items.map((item) => item['name'].toString()).join(', ');
      final orderTotal = items.fold(0.0, (sum, item) => sum + (item['price'] ?? 0).toDouble());

      final scheduled = (data['scheduledFor'] ?? data['timestamp']) as Timestamp;
      final scheduledDateStr = DateFormat('yyyy-MM-dd').format(scheduled.toDate());

      rows.add([
        'Order $orderNo',
        scheduledDateStr,
        itemNames,
        orderTotal.toStringAsFixed(2),
      ]);

      totalSales += orderTotal;
      orderNo++;
    }

    rows.add([]);
    rows.add(['', '', 'Total Sales', totalSales.toStringAsFixed(2)]);

    final csv = const ListToCsvConverter().convert(rows);
    final bytes = utf8.encode(csv);
    final blob = html.Blob([bytes]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "sales_report.csv")
      ..click();
    html.Url.revokeObjectUrl(url);
  }

  Widget _buildFilterButtons() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.calendar_today),
          label: const Text("Pick Date"),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(2024),
              lastDate: DateTime.now().add(const Duration(days: 30)), // Allow future
            );
            if (picked != null) {
              setState(() {
                _selectedDate = picked;
                _selectedDateRange = null;
                _selectedMonth = null;
              });
            }
          },
        ),
        ElevatedButton.icon(
          icon: const Icon(Icons.date_range),
          label: const Text("Date Range"),
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2024),
              lastDate: DateTime.now().add(const Duration(days: 30)),
            );
            if (picked != null) {
              setState(() {
                _selectedDateRange = picked;
                _selectedDate = null;
                _selectedMonth = null;
              });
            }
          },
        ),
        DropdownButton<String>(
          hint: const Text("Select Month"),
          value: _selectedMonth,
          items: _months.map((month) {
            return DropdownMenuItem(
              value: month,
              child: Text(DateFormat('MMMM yyyy').format(DateFormat('MM-yyyy').parse(month))),
            );
          }).toList(),
          onChanged: (value) {
            setState(() {
              _selectedMonth = value;
              _selectedDate = null;
              _selectedDateRange = null;
            });
          },
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.clear),
          label: const Text("Reset"),
          onPressed: () {
            setState(() {
              _selectedDate = null;
              _selectedDateRange = null;
              _selectedMonth = null;
            });
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sales Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () async {
              final docs = await _getFilteredOrders();
              _downloadCSV(docs);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<QueryDocumentSnapshot>>(
        future: _getFilteredOrders(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data ?? [];

          if (docs.isEmpty) {
            return const Center(child: Text("No orders found for selected filter."));
          }

          final totalSales = _calculateTotalSales(docs);

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFilterButtons(),
                const SizedBox(height: 20),
                Text(
                  'Total Orders: ${docs.length}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Text(
                  'Total Sales: ₹${totalSales.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Divider(height: 30),
                Expanded(
                  child: ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final data = docs[index].data() as Map<String, dynamic>;
                      final items = List<Map<String, dynamic>>.from(data['items']);
                      final orderTotal = items.fold(0.0, (sum, item) => sum + (item['price'] ?? 0).toDouble());

                      final scheduledDate = ((data['scheduledFor'] ?? data['timestamp']) as Timestamp).toDate();
                      final formattedDate = DateFormat('yyyy-MM-dd – hh:mm a').format(scheduledDate);

                      return Card(
                        elevation: 2,
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text('Order ${index + 1}'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Delivery Date: $formattedDate', style: const TextStyle(fontWeight: FontWeight.w500)),
                              const SizedBox(height: 5),
                              ...items.map((item) => Text('${item['name']} - ₹${item['price']}')).toList(),
                            ],
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
