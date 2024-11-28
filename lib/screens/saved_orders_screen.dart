import 'package:flutter/material.dart';
import '../services/firestore_service.dart';
import 'edit_order_screen.dart';

class SavedOrdersScreen extends StatefulWidget {
  const SavedOrdersScreen({Key? key}) : super(key: key);

  @override
  State<SavedOrdersScreen> createState() => _SavedOrdersScreenState();
}

class _SavedOrdersScreenState extends State<SavedOrdersScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _queryController = TextEditingController();
  List<Map<String, dynamic>> _filteredOrders = [];
  List<Map<String, dynamic>> _allOrders = [];

  @override
  void initState() {
    super.initState();
    _firestoreService.getOrderPlans().listen((orders) {
      setState(() {
        _allOrders = orders;
        _filteredOrders = orders;
      });
    });
  }

  void _filterOrders() {
    final query = _queryController.text.trim();
    if (query.isEmpty) {
      setState(() {
        _filteredOrders = _allOrders;
      });
    } else {
      setState(() {
        _filteredOrders = _allOrders
            .where((order) =>
        order['date'] != null && order['date'].toString().contains(query))
            .toList();
      });
    }
  }

  Future<List<String>> _getItemNames(List<String> itemIds) async {
    List<String> itemNames = [];
    for (String id in itemIds) {
      final item = await _firestoreService.getFoodItemById(id);
      if (item != null) {
        itemNames.add(item['name']);
      }
    }
    return itemNames;
  }

  Future<void> _editOrder(BuildContext context, Map<String, dynamic> order) async {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditOrderPage(order: order),
      ),
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
            const Text(
              'Saved Orders',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 16),

            // Search bar
            TextField(
              controller: _queryController,
              decoration: const InputDecoration(
                labelText: 'Search by Date',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              ),
              onChanged: (_) => _filterOrders(),
            ),
            const SizedBox(height: 16),

            // Orders list
            Expanded(
              child: ListView.builder(
                itemCount: _filteredOrders.length,
                itemBuilder: (context, index) {
                  final order = _filteredOrders[index];
                  final date = order['date'] ?? "Unknown Date";
                  final targetCost = order['targetCost'] ?? 0.0;
                  final totalCost = order['totalCost'] ?? 0.0;
                  final selectedItems = List<String>.from(order['selectedItems'] ?? []);

                  return FutureBuilder<List<String>>(
                    future: _getItemNames(selectedItems),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError || !snapshot.hasData) {
                        return ListTile(
                          title: Text('Date: $date'),
                          subtitle: const Text('Error fetching item names.'),
                        );
                      }

                      final itemNames = snapshot.data!;
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        elevation: 4.0,  // Add shadow for better visual separation
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
                        child: ListTile(
                          title: Text('Date: $date', style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Items: ${itemNames.isNotEmpty ? itemNames.join(", ") : "No Items"}'),
                              Text('Target Cost: \$${targetCost.toStringAsFixed(2)}'),
                              Text('Total Cost: \$${totalCost.toStringAsFixed(2)}'),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.grey),
                                onPressed: () => _editOrder(context, order),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Color(0xFF2C2C2C)),
                                onPressed: () async {
                                  await _firestoreService.deleteOrder(order['id']);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Order deleted successfully')),
                                  );
                                },
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
