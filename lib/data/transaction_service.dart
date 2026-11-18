import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/transaction.dart';

typedef AssetLoader = Future<String> Function(String path);

abstract class TransactionService {
  Future<List<Transaction>> getTransactions();
  Future<void> addTransaction(Transaction transaction);
  Future<void> deleteTransaction(String id);
}

class LocalTransactionService implements TransactionService {
  static const storageKey = 'transactions_v1';
  static const defaultAssetPath = 'assets/data/transactions.json';

  final SharedPreferences _prefs;
  final String assetPath;
  final AssetLoader _loadAsset;

  LocalTransactionService(
    this._prefs, {
    required this.assetPath,
    AssetLoader? assetLoader,
  }) : _loadAsset = assetLoader ?? rootBundle.loadString;

  @override
  Future<List<Transaction>> getTransactions() async {
    final saved = _prefs.getString(storageKey);
    if (saved != null) return _decode(saved);

    final seed = await _loadAsset(assetPath);
    final items = _decode(seed);
    await _save(items);
    return items;
  }

  @override
  Future<void> addTransaction(Transaction transaction) async {
    final items = await getTransactions();
    items.add(transaction);
    await _save(items);
  }

  @override
  Future<void> deleteTransaction(String id) async {
    final items = await getTransactions();
    items.removeWhere((t) => t.id == id);
    await _save(items);
  }

  List<Transaction> _decode(String raw) {
    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((e) => Transaction.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> _save(List<Transaction> items) async {
    final ok = await _prefs.setString(
      storageKey,
      jsonEncode(items.map((e) => e.toJson()).toList()),
    );
    if (!ok) throw Exception('Penyimpanan gagal');
  }
}