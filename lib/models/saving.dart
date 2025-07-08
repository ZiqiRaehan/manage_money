class Saving {
  final int? id;
  final String type; // 'plan' or 'actual'
  final String title;
  final double amount;
  final DateTime date;
  final DateTime? targetDate;
  final String? description;
  final bool isCompleted;

  Saving({
    this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.date,
    this.targetDate,
    this.description,
    this.isCompleted = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'type': type,
      'title': title,
      'amount': amount,
      'date': date.toIso8601String(),
      'targetDate': targetDate?.toIso8601String(),
      'description': description,
      'isCompleted': isCompleted ? 1 : 0,
    };
  }

  factory Saving.fromMap(Map<String, dynamic> map) {
    return Saving(
      id: map['id'],
      type: map['type'],
      title: map['title'],
      amount: map['amount'],
      date: DateTime.parse(map['date']),
      targetDate: map['targetDate'] != null ? DateTime.parse(map['targetDate']) : null,
      description: map['description'],
      isCompleted: map['isCompleted'] == 1,
    );
  }

  Saving copyWith({
    int? id,
    String? type,
    String? title,
    double? amount,
    DateTime? date,
    DateTime? targetDate,
    String? description,
    bool? isCompleted,
  }) {
    return Saving(
      id: id ?? this.id,
      type: type ?? this.type,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      targetDate: targetDate ?? this.targetDate,
      description: description ?? this.description,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}