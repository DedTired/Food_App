import 'food_item.dart';

class OrderPlan {
  String date;
  List<FoodItem> selectedItems;
  double targetCost;

  OrderPlan({required this.date, required this.selectedItems, required this.targetCost});

  Map<String, dynamic> toMap() {
    return {
      'date': date,
      'selected_items': selectedItems.map((item) => item.toMap()).toList(),
      'target_cost': targetCost,
    };
  }

  factory OrderPlan.fromMap(Map<String, dynamic> map) {
    return OrderPlan(
      date: map['date'],
      selectedItems: (map['selected_items'] as List<dynamic>)
          .map((item) => FoodItem.fromMap(item))
          .toList(),
      targetCost: map['target_cost'],
    );
  }
}
