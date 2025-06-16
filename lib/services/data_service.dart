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
      return snapshot.docs.map((doc) => MenuItem.fromFirestore(doc)).toList();
    });
  }

  Future<void> updateMenu(List<MenuItem> newItems) async {
    final menuRef = _db.collection('menuItems');
    final existingSnapshot = await menuRef.get();
    final batch = _db.batch();

    for (var doc in existingSnapshot.docs) {
      batch.delete(doc.reference);
    }

    for (var item in newItems) {
      final docRef = menuRef.doc();
      batch.set(docRef, item.toMap());
    }

    await batch.commit();
  }

  // ------------------ ORDERS ------------------

  Future<int> placeOrder(Map<MenuItem, int> cart, {required DateTime scheduledDate}) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception("User not logged in");

    final now = DateTime.now();
    final isToday = scheduledDate.year == now.year &&
                    scheduledDate.month == now.month &&
                    scheduledDate.day == now.day;

    final cutoffTime = DateTime(now.year, now.month, now.day, 13, 35); // 1:35 PM

    if (isToday && now.isAfter(cutoffTime)) {
      throw Exception("⚠️ Ordering for today is closed after 1:35 PM. Please choose another day.");
    }

    final scheduledDateOnly = DateTime(scheduledDate.year, scheduledDate.month, scheduledDate.day);
    final scheduledDateString = "${scheduledDate.year}-${scheduledDate.month}-${scheduledDate.day}";

    final settingsRef = _db.collection('settings').doc('tokenTracker_$scheduledDateString');
    final snapshot = await settingsRef.get();

    int newToken = 1;
    if (snapshot.exists) {
      final data = snapshot.data()!;
      newToken = (data['lastToken'] ?? 0) + 1;
    }

    await settingsRef.set({
      'lastToken': newToken,
      'date': Timestamp.fromDate(scheduledDateOnly),
    });

    final email = user.email ?? '';
    final username = _extractNameFromEmail(email);

    final orderData = {
      'userId': user.uid,
      'username': username,
      'token': newToken,
      'items': cart.entries.map((entry) => {
        'name': entry.key.name,
        'price': entry.key.price,
        'quantity': entry.value,
      }).toList(),
      'timestamp': Timestamp.now(),
      'scheduledFor': Timestamp.fromDate(scheduledDateOnly),
      'status': 'Pending',
    };

    await _db.collection('orders').add(orderData);
    return newToken;
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

  Future<List<UserOrder>> getTodayOrders() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = startOfDay.add(const Duration(days: 1));

    final snapshot = await _db
        .collection('orders')
        .where('scheduledFor', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfDay))
        .where('scheduledFor', isLessThan: Timestamp.fromDate(endOfDay))
        .get();

    return snapshot.docs.map((doc) => UserOrder.fromMap(doc.id, doc.data())).toList();
  }

  // ------------------ HELPER ------------------

  String _extractNameFromEmail(String email) {
    final localPart = email.split('@').first;
    final parts = localPart.split('.');
    if (parts.isEmpty) return 'User';

    final first = parts[0];
    return _capitalize(first); // Only return the first part
  }

  String _capitalize(String str) {
    return str.isEmpty ? str : '${str[0].toUpperCase()}${str.substring(1).toLowerCase()}';
  }
}
