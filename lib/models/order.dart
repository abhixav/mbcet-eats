import 'menu_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserOrder {
  final String id;
  final String userId;
  final String username;
  final int token;
  final List<MenuItem> items;
  final DateTime timestamp;
  final String status;

  UserOrder({
    required this.id,
    required this.userId,
    required this.username,
    required this.token,
    required this.items,
    required this.timestamp,
    required this.status,
  });

  factory UserOrder.fromMap(String id, Map<String, dynamic> map) {
    return UserOrder(
      id: id,
      userId: map['userId'] ?? '',
      username: map['username'] ?? '',
      token: map['token'] ?? 0,
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      status: map['status'] ?? 'Pending',
      items: (map['items'] as List).map((item) {
        return MenuItem(
          name: item['name'],
          price: item['price'],
        );
      }).toList(),
    );
  }
}
