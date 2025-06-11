class MenuItem {
  final String name;
  final int price;

  const MenuItem({required this.name, required this.price});

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      name: map['name'] ?? '',
      price: (map['price'] is int)
          ? map['price']
          : (map['price'] is double)
              ? (map['price'] as double).toInt()
              : int.tryParse(map['price'].toString()) ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {'name': name, 'price': price};
  }
}
