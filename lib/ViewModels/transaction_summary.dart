class TransactionSummary {
  final int totalIncome;
  final int totalExpense;
  final int balance;

  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.balance,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionSummary &&
          other.totalIncome == totalIncome &&
          other.totalExpense == totalExpense &&
          other.balance == balance;

  @override
  int get hashCode => Object.hash(totalIncome, totalExpense, balance);
}