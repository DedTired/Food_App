class FoodItem {
  final String id;
  final String name;
  final double cost;

  FoodItem({required this.id, required this.name, required this.cost});

  factory FoodItem.fromMap(Map<String, dynamic> map) {
    return FoodItem(
      id: map['id'] ?? '',
      name: map['name'] ?? 'Unnamed',
      cost: (map['cost'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'cost': cost,
    };
  }
}
