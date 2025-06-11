import 'menu_item.dart';

class UserOrder {
  final String id;
  final String username;
  final int token;
  final List<MenuItem> items;

  UserOrder({
    required this.id,
    required this.username,
    required this.token,
    required this.items,
  });

  factory UserOrder.fromMap(String id, Map<String, dynamic> data) {
    final itemsData = data['items'] as List<dynamic>;
    final itemsList = itemsData.map((item) => MenuItem(
      name: item['name'],
      price: item['price'],
    )).toList();

    return UserOrder(
      id: id,
      username: data['username'],
      token: data['token'],
      items: itemsList,
    );
  }
}
