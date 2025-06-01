class Meal {
  final int? id;
  final String name;
  final double calories;
  final double quantity;
  final DateTime? createdAt;

  Meal({
    this.id,
    required this.name,
    required this.calories,
    required this.quantity,
    this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'calories': calories,
      'quantity': quantity,
      'created_at':
          createdAt?.toIso8601String() ?? DateTime.now().toIso8601String(),
    };
  }

  factory Meal.fromMap(Map<String, dynamic> map) {
    return Meal(
      id: map['id'],
      name: map['name'],
      calories: map['calories'],
      quantity: map['quantity'],
      createdAt: DateTime.parse(map['created_at']),
    );
  }

  @override
  String toString() {
    return 'Meal{id: $id, name: $name, calories: $calories, quantity: $quantity, createdAt: $createdAt}';
  }
}
