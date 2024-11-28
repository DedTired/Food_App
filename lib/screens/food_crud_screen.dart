import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class FoodCRUDScreen extends StatefulWidget {
  const FoodCRUDScreen({Key? key}) : super(key: key);

  @override
  State<FoodCRUDScreen> createState() => _FoodCRUDScreenState();
}

class _FoodCRUDScreenState extends State<FoodCRUDScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  String? _editingFoodId;

  void _saveFoodItem() async {
    final name = _nameController.text.trim();
    final cost = double.tryParse(_costController.text) ?? 0.0;

    if (name.isNotEmpty && cost > 0) {
      if (_editingFoodId != null) {
        await _firestoreService.updateFoodItem(_editingFoodId!, name, cost);
      } else {
        await _firestoreService.addFoodItem(name, cost);
      }
      _nameController.clear();
      _costController.clear();
      _editingFoodId = null;
      setState(() {});
    }
  }

  // Open an edit dialog instead of directly editing the fields
  void _editFoodItem(Map<String, dynamic> foodItem) {
    // Set the editing food ID and populate the fields
    _editingFoodId = foodItem['id'];
    _nameController.text = foodItem['name'];
    _costController.text = foodItem['cost'].toString();

    // Show the edit dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Edit Food Item'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                // Food Name Field
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Food Name'),
                ),
                const SizedBox(height: 8),
                // Food Cost Field
                TextField(
                  controller: _costController,
                  decoration: const InputDecoration(labelText: 'Food Cost'),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            // Save Changes Button
            ElevatedButton(
              onPressed: () {
                _saveFoodItem(); // Save the changes
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save Changes'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.orange,
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food App'),
        centerTitle: true,
        backgroundColor: const Color(0xFF2C2C2C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Add Subheader here, not in AppBar
            const Text(
              'Manage Food Items',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),

            // Food Item Form
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Food Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _costController,
              decoration: const InputDecoration(
                labelText: 'Food Cost',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _saveFoodItem,
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black,
                backgroundColor: Colors.orange, // Text color (black)
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _editingFoodId == null ? 'Add Food Item' : 'Update Food Item',
                style: const TextStyle(fontSize: 16),
              ),
            ),
            const Divider(),
            Expanded(
              child: StreamBuilder(
                stream: _firestoreService.getFoodItems(),
                builder: (context, snapshot) {
                  // Handle loading and error states
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (snapshot.hasError || !snapshot.hasData || snapshot.data is! List) {
                    return const Center(child: Text("Error fetching data"));
                  }

                  // Safely cast data to List<Map<String, dynamic>>
                  final foodItems = snapshot.data as List<Map<String, dynamic>>;

                  // Ensure itemCount is correct
                  return ListView.builder(
                    itemCount: foodItems.length,
                    itemBuilder: (context, index) {
                      final item = foodItems[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 5, // Add shadow to the card
                        child: ListTile(
                          title: Text('${item['name']} - \$${item['cost']}'),
                          subtitle: Text('Cost: \$${item['cost']}'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                onPressed: () => _editFoodItem(item),  // Trigger the edit dialog
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Color(0xFF2C2C2C)),
                                onPressed: () => _firestoreService.deleteFoodItem(item['id']),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
