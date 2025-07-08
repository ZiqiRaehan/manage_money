class Expense {
  final int? id;
  final String item;
  final double price;
  final int quantity;
  final DateTime date;
  final String category;
  final String? description;

  Expense({
    this.id,
    required this.item,
    required this.price,
    required this.quantity,
    required this.date,
    required this.category,
    this.description,
  });

  double get totalAmount => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'item': item,
      'price': price,
      'quantity': quantity,
      'date': date.toIso8601String(),
      'category': category,
      'description': description,
    };
  }

  factory Expense.fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      item: map['item'],
      price: map['price'],
      quantity: map['quantity'],
      date: DateTime.parse(map['date']),
      category: map['category'],
      description: map['description'],
    );
  }

  Expense copyWith({
    int? id,
    String? item,
    double? price,
    int? quantity,
    DateTime? date,
    String? category,
    String? description,
  }) {
    return Expense(
      id: id ?? this.id,
      item: item ?? this.item,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      date: date ?? this.date,
      category: category ?? this.category,
      description: description ?? this.description,
    );
  }
}