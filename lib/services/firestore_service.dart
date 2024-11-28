import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Add Food Item
  Future<void> addFoodItem(String name, double cost) async {
    await _db.collection('food_items').add({'name': name, 'cost': cost});
  }

  // Get Food Items
  Stream<List<Map<String, dynamic>>> getFoodItems() {
    return _db.collection('food_items').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  // Update Food Item
  Future<void> updateFoodItem(String id, String name, double cost) async {
    await _db.collection('food_items').doc(id).update({'name': name, 'cost': cost});
  }

  // Delete Food Item
  Future<void> deleteFoodItem(String id) async {
    await _db.collection('food_items').doc(id).delete();
  }

  // Save Order Plan
  Future<void> saveOrderPlan(
      String date,
      double targetCost,
      List<String> selectedItems,
      double totalCost,
      ) async {
    await _db.collection('order_plans').add({
      'date': date,
      'targetCost': targetCost,
      'selectedItems': selectedItems,
      'totalCost': totalCost,
    });
  }

  // Get Order Plans
  Stream<List<Map<String, dynamic>>> getOrderPlans() {
    return _db.collection('order_plans').snapshots().map((snapshot) =>
        snapshot.docs.map((doc) => {...doc.data(), 'id': doc.id}).toList());
  }

  // Delete Order Plan
  Future<void> deleteOrder(String id) async {
    await _db.collection('order_plans').doc(id).delete();
  }

  // Update Order Plan
  Future<void> updateOrder(String id, Map<String, dynamic> updatedData) async {
    await _db.collection('order_plans').doc(id).update(updatedData);
  }

  // Get Food Item by ID
  Future<Map<String, dynamic>?> getFoodItemById(String id) async {
    final doc = await _db.collection('food_items').doc(id).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }
}
