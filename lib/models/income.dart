class Income {
  final int? id;
  final String source; // 'salary', 'freelance', 'found', 'other'
  final double amount;
  final DateTime date;
  final String description;

  Income({
    this.id,
    required this.source,
    required this.amount,
    required this.date,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'source': source,
      'amount': amount,
      'date': date.toIso8601String(),
      'description': description,
    };
  }

  factory Income.fromMap(Map<String, dynamic> map) {
    return Income(
      id: map['id'],
      source: map['source'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      description: map['description'],
    );
  }

  Income copyWith({
    int? id,
    String? source,
    double? amount,
    DateTime? date,
    String? description,
  }) {
    return Income(
      id: id ?? this.id,
      source: source ?? this.source,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      description: description ?? this.description,
    );
  }
}