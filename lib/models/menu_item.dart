class MenuItem {
  final String name;
  final int price;

  MenuItem({required this.name, required this.price});

  factory MenuItem.fromMap(Map<String, dynamic> data) {
    return MenuItem(
      name: data['name'] ?? '',
      price: data['price'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'price': price,
    };
  }
}
