import '../core/failure.dart';
import '../models/transaction.dart';
import '../data/transaction_service.dart';
import '../domain/transaction_repository.dart';

class TransactionRepositoryImpl implements TransactionRepository {
  final TransactionService _service;
  const TransactionRepositoryImpl(this._service);

  @override
  Future<List<Transaction>> getTransactions() async {
    try {
      return await _service.getTransactions();
    } catch (_) {
      throw const Failure('Gagal memuat data transaksi. Silakan coba lagi.');
    }
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    try {
      await _service.addTransaction(transaction);
    } catch (_) {
      throw const Failure('Transaksi gagal disimpan. Silakan coba lagi.');
    }
  }

  @override
  Future<void> deleteTransaction(String id) async {
    try {
      await _service.deleteTransaction(id);
    } catch (_) {
      throw const Failure('Transaksi gagal dihapus. Silakan coba lagi.');
    }
  }
}