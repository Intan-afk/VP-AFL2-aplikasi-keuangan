
enum TransactionType { income, expense }

class Transaction {
  final String id;
  final String title;

  final int amount;
  final TransactionType type;
  final DateTime date;

  const Transaction({
    required this.id,
    required this.title,
    required this.amount,
    required this.type,
    required this.date,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) => Transaction(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: json['amount'] as int,
        type: TransactionType.values.byName(json['type'] as String),
        date: DateTime.parse(json['date'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'type': type.name,
        'date': date.toIso8601String(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Transaction &&
          id == other.id &&
          title == other.title &&
          amount == other.amount &&
          type == other.type &&
          date == other.date;

  @override
  int get hashCode => Object.hash(id, title, amount, type, date);
}
