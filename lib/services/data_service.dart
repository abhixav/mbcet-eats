import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/menu_item.dart';
import '../models/order.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔐 Places an order and sets default status as 'Pending'
  Future<int> placeOrder(List<MenuItem> items) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final ordersSnapshot = await _db.collection('orders').get();
    final token = ordersSnapshot.size + 1;

    final email = user.email ?? '';
    final username = _extractNameFromEmail(email);

    final orderData = {
      'userId': user.uid,
      'username': username,
      'token': token,
      'items': items.map((e) => {'name': e.name, 'price': e.price}).toList(),
      'timestamp': Timestamp.now(),
      'status': 'Pending',
    };

    await _db.collection('orders').add(orderData);
    return token;
  }

  /// 📦 User-specific order stream
  Stream<List<UserOrder>> getOrders() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return const Stream.empty();

    return _db
        .collection('orders')
        .where('userId', isEqualTo: user.uid)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserOrder.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// 🧾 Admin stream for all orders
  Stream<List<UserOrder>> getAllOrders() {
    return _db
        .collection('orders')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return UserOrder.fromMap(doc.id, doc.data());
      }).toList();
    });
  }

  /// ✅ Mark an order as Completed instead of deleting
  Future<void> markOrderAsDone(String orderId) async {
    await _db.collection('orders').doc(orderId).update({'status': 'Completed'});
  }

  /// 📋 Menu stream
  Stream<List<MenuItem>> getMenuItems() {
    return _db.collection('menuItems').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return MenuItem.fromMap(doc.data());
        } catch (e) {
          print('⚠️ Skipped invalid menu item: ${doc.id}, error: $e');
          return null;
        }
      }).whereType<MenuItem>().toList();
    });
  }

  /// ✏️ Replace entire menu (admin)
  Future<void> updateMenu(List<MenuItem> items) async {
    final menuRef = _db.collection('menuItems');
    final batch = _db.batch();

    final oldMenu = await menuRef.get();
    for (final doc in oldMenu.docs) {
      batch.delete(doc.reference);
    }

    for (final item in items) {
      final newDoc = menuRef.doc();
      batch.set(newDoc, item.toMap());
    }

    await batch.commit();
  }

  /// 👤 Extract nice name from email
  String _extractNameFromEmail(String email) {
    final localPart = email.split('@').first;
    final parts = localPart.split('.');
    if (parts.isEmpty) return 'Unknown';

    final namePart = parts.first;
    final nameMatches = RegExp(r'[a-zA-Z]+').allMatches(namePart).map((m) => m.group(0) ?? '').toList();

    if (nameMatches.isEmpty) return namePart;

    final first = nameMatches[0];
    final last = nameMatches.length > 1 ? nameMatches[1][0].toUpperCase() : '';

    return '${_capitalize(first)} $last';
  }

  String _capitalize(String str) => str.isEmpty ? str : '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}';
}
