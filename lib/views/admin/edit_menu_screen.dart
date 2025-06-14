import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
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
  int? editingIndex;

  @override
  void initState() {
    super.initState();
    DataService().getMenuItems().listen((menu) {
      setState(() {
        items = List.from(menu);
      });
    });
  }

  void addOrUpdateItem() {
    final name = nameController.text.trim();
    final priceText = priceController.text.trim();

    if (name.isEmpty || priceText.isEmpty) return;

    final price = int.tryParse(priceText);
    if (price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("⚠️ Invalid price")),
      );
      return;
    }

    final id = editingIndex != null
        ? items[editingIndex!].id
        : const Uuid().v4();

    final newItem = MenuItem(id: id, name: name, price: price);

    setState(() {
      if (editingIndex != null) {
        items[editingIndex!] = newItem;
        editingIndex = null;
      } else {
        items.add(newItem);
      }
    });

    nameController.clear();
    priceController.clear();
  }

  void saveMenu() async {
    await DataService().updateMenu(items);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("✅ Menu updated successfully")),
    );
  }

  void deleteItem(int index) {
    setState(() {
      items.removeAt(index);
    });
  }

  void editItem(int index) {
    final item = items[index];
    nameController.text = item.name;
    priceController.text = item.price.toString();
    setState(() {
      editingIndex = index;
    });
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
            ElevatedButton(
              onPressed: addOrUpdateItem,
              child: Text(editingIndex == null ? "Add Item" : "Update Item"),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: items.length,
                itemBuilder: (_, index) => ListTile(
                  title: Text(items[index].name),
                  subtitle: Text("₹${items[index].price}"),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.orange),
                        onPressed: () => editItem(index),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => deleteItem(index),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: saveMenu,
              icon: const Icon(Icons.save),
              label: const Text("Save Menu"),
            ),
          ],
        ),
      ),
    );
  }
}
