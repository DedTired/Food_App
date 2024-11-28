import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class EditOrderPage extends StatefulWidget {
  final Map<String, dynamic> order; // Pass the order data to this page

  const EditOrderPage({Key? key, required this.order}) : super(key: key);

  @override
  State<EditOrderPage> createState() => _EditOrderPageState();
}

class _EditOrderPageState extends State<EditOrderPage> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _targetCostController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  Map<String, int> _itemQuantities = {}; // Store quantities for selected items
  List<String> _selectedItems = []; // Store selected food items
  double remainingBudget = 0.0;  // Remaining budget
  double totalCost = 0.0; // Track total cost dynamically

  @override
  void initState() {
    super.initState();
    _targetCostController.text = widget.order['targetCost']?.toString() ?? "0.0";
    _dateController.text = widget.order['date'] ?? "";
    _selectedItems = List<String>.from(widget.order['selectedItems'] ?? []);
    _calculateRemainingBudget();
  }

  // Calculate remaining budget based on selected items and their quantities
  void _calculateRemainingBudget() {
    final targetCost = double.tryParse(_targetCostController.text) ?? 0.0;
    totalCost = 0.0;

    // Calculate total cost based on selected items and their quantities
    for (var itemId in _selectedItems) {
      // Ensure foodItems list is not null and contains valid data
      final item = widget.order['foodItems']?.firstWhere((item) => item['id'] == itemId, orElse: () => null);
      if (item != null) {
        final itemQuantity = _itemQuantities[itemId] ?? 1;
        totalCost += item['cost'] * itemQuantity;
      }
    }

    setState(() {
      remainingBudget = targetCost - totalCost;
    });
  }

  // Update the quantity of an item
  void _updateQuantity(String itemId, int quantity) {
    setState(() {
      if (quantity >= 1) {
        _itemQuantities[itemId] = quantity;
        if (!_selectedItems.contains(itemId)) {
          _selectedItems.add(itemId);
        }
      }
    });
    _calculateRemainingBudget(); // Recalculate the remaining budget after quantity change
  }

  // Save the changes to Firestore
  void _saveChanges() async {
    final updatedData = {
      'targetCost': double.tryParse(_targetCostController.text) ?? 0.0,
      'selectedItems': _selectedItems,
      'date': _dateController.text,
    };
    await _firestoreService.updateOrder(widget.order['id'], updatedData);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Order updated successfully!')));
    Navigator.pop(context); // Return to the previous screen
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Order Plan'),
        backgroundColor: const Color(0xFF2C2C2C),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Edit Order Plan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),

            // Target Cost Field
            TextField(
              controller: _targetCostController,
              decoration: const InputDecoration(labelText: 'Target Cost per Day'),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateRemainingBudget(),
            ),
            const SizedBox(height: 16),

            // Date Field
            TextField(
              controller: _dateController,
              decoration: const InputDecoration(labelText: 'Select Date'),
              readOnly: true,
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime(2020),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  setState(() {
                    _dateController.text = date.toIso8601String().split('T').first;
                  });
                }
              },
            ),
            const SizedBox(height: 16),

            // Food Items List with quantity adjustment
            const Text('Select Food Items:'),
            Expanded(
              child: FutureBuilder<List<Map<String, dynamic>>>(
                future: _firestoreService.getFoodItems().first,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  }
                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text("No food items available.");
                  }

                  final foodItems = snapshot.data!;
                  return ListView(
                    children: foodItems.map((item) {
                      final itemQuantity = _itemQuantities[item['id']] ?? 1;

                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        child: ListTile(
                          title: Text('${item['name']} - \$${item['cost']}'),
                          subtitle: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.remove),
                                onPressed: itemQuantity > 0
                                    ? () {
                                  _updateQuantity(item['id'], itemQuantity - 1);
                                }
                                    : null,
                              ),
                              Text('$itemQuantity'),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  _updateQuantity(item['id'], itemQuantity + 1);
                                },
                              ),
                            ],
                          ),
                          trailing: Checkbox(
                            value: _selectedItems.contains(item['id']),
                            onChanged: (isSelected) {
                              setState(() {
                                if (isSelected ?? false) {
                                  _selectedItems.add(item['id']);
                                } else {
                                  _selectedItems.remove(item['id']);
                                }
                              });
                              _calculateRemainingBudget(); // Recalculate after selection change
                            },
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),

            // Remaining Budget Display
            const SizedBox(height: 16),
            Text(
              'Remaining Budget: \$${remainingBudget.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: remainingBudget < 0 ? Colors.red : Colors.green,
              ),
            ),
            const SizedBox(height: 16),

            // Save Button (disabled if over budget)
            ElevatedButton(
              onPressed: remainingBudget < 0 ? null : _saveChanges,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: remainingBudget < 0 ? Colors.grey : Colors.orange,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
