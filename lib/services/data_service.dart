import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/menu_item.dart';
import '../models/order.dart';

class DataService {
  static final DataService _instance = DataService._internal();
  factory DataService() => _instance;
  DataService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ------------------ MENU ------------------

  Stream<List<MenuItem>> getMenuItems() {
    return _db.collection('menuItems').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return MenuItem.fromFirestore(doc);
      }).toList();
    });
  }

  Future<void> updateMenu(List<MenuItem> newItems) async {
    final menuRef = _db.collection('menuItems');
    final existingSnapshot = await menuRef.get();
    final batch = _db.batch();

    // Delete old menu
    for (var doc in existingSnapshot.docs) {
      batch.delete(doc.reference);
    }

    // Add new menu
    for (var item in newItems) {
      final docRef = menuRef.doc(); // Auto-generated ID
      batch.set(docRef, item.toMap());
    }

    await batch.commit();
  }

  // ------------------ ORDERS ------------------

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

  Future<void> markOrderAsDone(String orderId) async {
    await _db.collection('orders').doc(orderId).update({'status': 'Completed'});
  }

  // ------------------ HELPER ------------------

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
