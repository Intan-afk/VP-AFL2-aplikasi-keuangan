import 'package:flutter/foundation.dart';

import '../core/failure.dart';
import '../domain/transaction_repository.dart';
import '../models/transaction.dart';
import 'error_viewmodel.dart';
import 'transaction_state.dart';
import 'transaction_summary.dart';

class TransactionViewModel extends ChangeNotifier {
  final TransactionRepository _repository;
  final ErrorViewModel _errors;

  TransactionViewModel({
    required TransactionRepository repository,
    required ErrorViewModel errorViewModel,
  }) : _repository = repository,
       _errors = errorViewModel;

  TransactionState _state = const TransactionInitial();
  bool _disposed = false;

  TransactionState get state => _state;

  void _emit(TransactionState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  Future<void> load() async {
    _errors.clear();
    _emit(const TransactionLoading());
    await _refresh();
  }

  Future<void> add({
    required String title,
    required int amount,
    required TransactionType type,
  }) async {
    final cleanTitle = title.trim();
    if (cleanTitle.isEmpty) {
      _errors.report(const Failure('Judul transaksi tidak boleh kosong.'));
      return;
    }
    if (amount <= 0) {
      _errors.report(const Failure('Nominal harus lebih besar dari nol.'));
      return;
    }
    final now = DateTime.now();
    try {
      await _repository.addTransaction(
        Transaction(
          id: now.microsecondsSinceEpoch.toString(),
          title: cleanTitle,
          amount: amount,
          type: type,
          date: now,
        ),
      );
      if (_disposed) return;
      await _refresh();
    } catch (e) {
      _errors.report(e); // daftar di layar tetap utuh
    }
  }

  Future<void> remove(String id) async {
    final previous = _state;
    if (previous is TransactionLoaded) {
      _emit(
        _buildState(previous.transactions.where((t) => t.id != id).toList()),
      );
    }
    try {
      await _repository.deleteTransaction(id);
      if (_disposed) return;
      await _refresh();
    } catch (e) {
      _emit(previous);
      _errors.report(e);
    }
  }

  Future<void> _refresh() async {
    try {
      final items = await _repository.getTransactions();
      if (_disposed) return;
      _emit(_buildState(items));
    } catch (e) {
      // Layar error penuh hanya bila belum ada data yang bisa ditampilkan.
      if (_state is TransactionInitial || _state is TransactionLoading) {
        _emit(const TransactionLoadFailed());
      }
      _errors.report(e);
    }
  }

  TransactionState _buildState(List<Transaction> items) {
    if (items.isEmpty) return const TransactionEmpty();

    final sorted = [...items]..sort((a, b) => b.date.compareTo(a.date));

    var income = 0;
    var expense = 0;
    for (final t in sorted) {
      if (t.type == TransactionType.income) {
        income += t.amount;
      } else {
        expense += t.amount;
      }
    }

    return TransactionLoaded(
      transactions: sorted,
      summary: TransactionSummary(
        totalIncome: income,
        totalExpense: expense,
        balance: income - expense,
      ),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
