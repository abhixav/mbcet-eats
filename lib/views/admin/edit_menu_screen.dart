import 'package:flutter/material.dart';
import '../../models/menu_item.dart';
import '../../services/data_service.dart';

class EditMenuScreen extends StatefulWidget {
  const EditMenuScreen({super.key});

  @override
  State<EditMenuScreen> createState() => _EditMenuScreenState();
}

class _EditMenuScreenState extends State<EditMenuScreen> {
  List<MenuItem> items = [];
  final nameController = TextEditingController();
  final priceController = TextEditingController();

  void addItem() {
    if (nameController.text.isEmpty || priceController.text.isEmpty) return;

    final item = MenuItem(name: nameController.text, price: int.parse(priceController.text));
    setState(() {
      items.add(item);
    });

    nameController.clear();
    priceController.clear();
  }

  void saveMenu() async {
    await DataService().updateMenu(items);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Menu updated.")));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Menu")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Item Name"),
            ),
            TextField(
              controller: priceController,
              decoration: const InputDecoration(labelText: "Price"),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 10),
            ElevatedButton(onPressed: addItem, child: const Text("Add Item")),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, i) => ListTile(
                  title: Text(items[i].name),
                  trailing: Text("₹${items[i].price}"),
                ),
              ),
            ),
            ElevatedButton(
              onPressed: saveMenu,
              child: const Text("Save Menu"),
            )
          ],
        ),
      ),
    );
  }
}
