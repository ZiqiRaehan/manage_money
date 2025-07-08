class Transaction {
  final int? id;
  final String type; // 'income' or 'expense'
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String? description;
  final int? quantity;

  Transaction({
    this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    this.description,
    this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'amount': amount,
      'category': category,
      'date': date.toIso8601String(),
      'description': description,
      'quantity': quantity,
    };
  }

  factory Transaction.fromMap(Map<String, dynamic> map) {
    return Transaction(
      id: map['id'],
      type: map['type'],
      title: map['title'],
      amount: map['amount'],
      category: map['category'],
      date: DateTime.parse(map['date']),
      description: map['description'],
      quantity: map['quantity'],
    );
  }

  Transaction copyWith({
    int? id,
    String? type,
    String? title,
    double? amount,
    String? category,
    DateTime? date,
    String? description,
    int? quantity,
  }) {
    return Transaction(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      category: category ?? this.category,
      date: date ?? this.date,
      description: description ?? this.description,
      quantity: quantity ?? this.quantity,
    );
  }
}