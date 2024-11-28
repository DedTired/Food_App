import 'package:flutter/material.dart';
import '../services/firestore_service.dart';

class OrderPlanScreen extends StatefulWidget {
  const OrderPlanScreen({Key? key}) : super(key: key);

  @override
  State<OrderPlanScreen> createState() => _OrderPlanScreenState();
}

class _OrderPlanScreenState extends State<OrderPlanScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _targetCostController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _searchController = TextEditingController(); // Controller for search
  List<Map<String, dynamic>> _foodItems = [];
  List<String> _selectedItems = [];
  Map<String, int> _itemQuantities = {}; // To store quantities for selected items
  double remainingBudget = 0.0;

  @override
  void initState() {
    super.initState();
    _firestoreService.getFoodItems().listen((items) {
      setState(() {
        _foodItems = items;
      });
    });
  }

  void _calculateRemainingBudget() {
    final targetCost = double.tryParse(_targetCostController.text) ?? 0.0;
    final totalCost = _selectedItems.fold<double>(
      0.0,
          (sum, id) =>
      sum + _foodItems.firstWhere((item) => item['id'] == id)['cost'] * (_itemQuantities[id] ?? 0),
    );
    setState(() {
      remainingBudget = targetCost - totalCost;
    });
  }

  void _saveOrderPlan() async {
    final targetCost = double.tryParse(_targetCostController.text) ?? 0.0;
    if (_selectedItems.isEmpty || _dateController.text.isEmpty || targetCost <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields and select items.')),
      );
      return;
    }

    final totalCost = _selectedItems.fold<double>(
      0.0,
          (sum, id) =>
      sum + _foodItems.firstWhere((item) => item['id'] == id)['cost'] * (_itemQuantities[id] ?? 0),
    );

    await _firestoreService.saveOrderPlan(
      _dateController.text,
      targetCost,
      _selectedItems,
      totalCost,
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Order plan saved successfully!')),
    );

    setState(() {
      _targetCostController.clear();
      _dateController.clear();
      _selectedItems.clear();
      _itemQuantities.clear();
      remainingBudget = 0.0;
    });
  }

  // Increase or Decrease Item Quantity
  void _updateQuantity(String itemId, int quantity) {
    setState(() {
      if (quantity >= 0) {
        _itemQuantities[itemId] = quantity;
        if (quantity > 0) {
          // Only add the item to selected list if the quantity is greater than 0
          if (!_selectedItems.contains(itemId)) {
            _selectedItems.add(itemId);
          }
        } else {
          // Remove the item from selected list if quantity is 0
          _selectedItems.remove(itemId);
        }
      }
    });
    _calculateRemainingBudget();
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title for the page
            const Text(
              'Create Order Plan',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black),
            ),
            const SizedBox(height: 16),

            // Target Cost Field with modern input decoration
            TextField(
              controller: _targetCostController,
              decoration: InputDecoration(
                labelText: 'Target Cost per Day',
                hintText: 'Enter your target cost for the day',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.attach_money),
              ),
              keyboardType: TextInputType.number,
              onChanged: (_) => _calculateRemainingBudget(),
            ),
            const SizedBox(height: 16),

            // Date Field with date picker
            TextField(
              controller: _dateController,
              decoration: InputDecoration(
                labelText: 'Select Date',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                prefixIcon: const Icon(Icons.calendar_today),
              ),
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

            // Search bar to filter food items
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                labelText: 'Search Food Items',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 16),

            // Food Items List with quantity controls
            Expanded(
              child: ListView.builder(
                itemCount: _foodItems.length,
                itemBuilder: (context, index) {
                  final item = _foodItems[index];
                  final itemQuantity = _itemQuantities[item['id']] ?? 0;

                  // Filter food items based on search query
                  if (_searchController.text.isNotEmpty &&
                      !item['name'].toString().toLowerCase().contains(_searchController.text.toLowerCase())) {
                    return Container(); // Skip rendering if it doesn't match search query
                  }

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    elevation: 5,
                    child: ListTile(
                      title: Text('${item['name']} - \$${item['cost']}'),
                      subtitle: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          // Quantity Buttons
                          IconButton(
                            icon: const Icon(Icons.remove),
                            onPressed: itemQuantity > 0
                                ? () => _updateQuantity(item['id'], itemQuantity - 1)
                                : null,
                          ),
                          Text('$itemQuantity'),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () => _updateQuantity(item['id'], itemQuantity + 1),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            // Remaining Budget Display with styling
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

            // Save Button with modern style
            ElevatedButton(
              onPressed: remainingBudget < 0 ? null : _saveOrderPlan,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: remainingBudget < 0 ? Colors.grey : Colors.orange,
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              ),
              child: const Text(
                'Save Order Plan',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
