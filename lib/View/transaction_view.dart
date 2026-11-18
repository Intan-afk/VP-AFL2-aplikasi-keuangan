import 'package:flutter/material.dart';

import '../models/transaction.dart';
import '../viewmodels/error_state.dart';
import '../viewmodels/error_viewmodel.dart';
import '../viewmodels/transaction_state.dart';
import '../viewmodels/transaction_viewmodel.dart';
import '../core/format.dart';
import 'widgets/add_transaction_dialog.dart';

class TransactionView extends StatelessWidget {
  final TransactionViewModel transactionViewModel;
  final ErrorViewModel errorViewModel;

  const TransactionView({
    super.key,
    required this.transactionViewModel,
    required this.errorViewModel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pencatat Keuangan')),
      body: _ErrorListener(
        errors: errorViewModel,
        transactions: transactionViewModel,
        child: ListenableBuilder(
          listenable: transactionViewModel,
          builder: (context, _) {
            return switch (transactionViewModel.state) {
              TransactionInitial() || TransactionLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              TransactionEmpty() => const _EmptyView(),
              final TransactionLoaded loaded => _LoadedView(
                state: loaded,
                onRemove: transactionViewModel.remove,
              ),
              TransactionLoadFailed() => _ErrorView(
                errors: errorViewModel,
                onRetry: transactionViewModel.load,
              ),
            };
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openDialog(context),
        child: const Icon(Icons.add),
      ),
    );
  }

  void _openDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AddTransactionDialog(
        onSubmit: (title, amount, type) =>
            transactionViewModel.add(title: title, amount: amount, type: type),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Text(
          'Belum ada transaksi.\nKetuk tombol + untuk menambahkan.',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _ErrorListener extends StatefulWidget {
  final ErrorViewModel errors;
  final TransactionViewModel transactions;
  final Widget child;

  const _ErrorListener({
    required this.errors,
    required this.transactions,
    required this.child,
  });

  @override
  State<_ErrorListener> createState() => _ErrorListenerState();
}

class _ErrorListenerState extends State<_ErrorListener> {
  @override
  void initState() {
    super.initState();
    widget.errors.addListener(_onError);
  }

  void _onError() {
    final error = widget.errors.state;
    if (error is! HasError || !mounted) return;
    if (widget.transactions.state is TransactionLoadFailed) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(error.message)));
    widget.errors.clear();
  }

  @override
  void dispose() {
    widget.errors.removeListener(_onError);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

class _ErrorView extends StatelessWidget {
  final ErrorViewModel errors;
  final VoidCallback onRetry;

  const _ErrorView({required this.errors, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: errors,
      builder: (context, _) {
        final message = switch (errors.state) {
          HasError(:final message) => message,
          NoError() => 'Terjadi kesalahan. Silakan coba lagi.',
        };
        return Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
                const SizedBox(height: 12),
                FilledButton(
                  onPressed: onRetry,
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _LoadedView extends StatelessWidget {
  final TransactionLoaded state;
  final void Function(String id) onRemove;

  const _LoadedView({required this.state, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final summary = state.summary;
    return Column(
      children: [
        Card(
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Saldo'),
                Text(
                  formatRupiah(summary.balance),
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Masuk: ${formatRupiah(summary.totalIncome)}'),
                    Text('Keluar: ${formatRupiah(summary.totalExpense)}'),
                  ],
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: state.transactions.length,
            itemBuilder: (context, i) {
              final t = state.transactions[i];
              final isIncome = t.type == TransactionType.income;
              return Dismissible(
                key: ValueKey(t.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 16),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (_) => onRemove(t.id),
                child: ListTile(
                  leading: Icon(
                    isIncome ? Icons.arrow_downward : Icons.arrow_upward,
                    color: isIncome ? Colors.green : Colors.red,
                  ),
                  title: Text(t.title),
                  subtitle: Text(formatTanggal(t.date)),
                  trailing: Text(
                    '${isIncome ? '+' : '-'}${formatRupiah(t.amount)}',
                    style: TextStyle(
                      color: isIncome ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
