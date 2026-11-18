import 'package:flutter/foundation.dart' show listEquals;

import '../models/transaction.dart';
import 'transaction_summary.dart';

sealed class TransactionState {
  const TransactionState();
}

final class TransactionInitial extends TransactionState {
  const TransactionInitial();

  @override
  bool operator ==(Object other) => other is TransactionInitial;

  @override
  int get hashCode => (TransactionInitial).hashCode;
}

final class TransactionLoading extends TransactionState {
  const TransactionLoading();

  @override
  bool operator ==(Object other) => other is TransactionLoading;

  @override
  int get hashCode => (TransactionLoading).hashCode;
}

final class TransactionEmpty extends TransactionState {
  const TransactionEmpty();

  @override
  bool operator ==(Object other) => other is TransactionEmpty;

  @override
  int get hashCode => (TransactionEmpty).hashCode;
}

final class TransactionLoaded extends TransactionState {
  final List<Transaction> transactions;
  final TransactionSummary summary;

  const TransactionLoaded({required this.transactions, required this.summary});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionLoaded &&
          listEquals(other.transactions, transactions) &&
          other.summary == summary;

  @override
  int get hashCode => Object.hash(Object.hashAll(transactions), summary);
}

final class TransactionLoadFailed extends TransactionState {
  const TransactionLoadFailed();

  @override
  bool operator ==(Object other) => other is TransactionLoadFailed;

  @override
  int get hashCode => (TransactionLoadFailed).hashCode;
}