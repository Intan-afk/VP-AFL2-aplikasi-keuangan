import 'package:flutter/material.dart';

import '../../models/transaction.dart';

class AddTransactionDialog extends StatefulWidget {
  final void Function(String title, int amount, TransactionType type) onSubmit;

  const AddTransactionDialog({super.key, required this.onSubmit});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  TransactionType _type = TransactionType.expense;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    widget.onSubmit(
      _titleController.text.trim(),
      int.parse(_amountController.text.trim()),
      _type,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Tambah Transaksi'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SegmentedButton<TransactionType>(
              segments: const [
                ButtonSegment(
                    value: TransactionType.expense, label: Text('Pengeluaran')),
                ButtonSegment(
                    value: TransactionType.income, label: Text('Pemasukan')),
              ],
              selected: {_type},
              onSelectionChanged: (s) => setState(() => _type = s.first),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Judul'),
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Judul tidak boleh kosong'
                  : null,
            ),
            TextFormField(
              controller: _amountController,
              decoration: const InputDecoration(labelText: 'Nominal (Rp)'),
              keyboardType: TextInputType.number,
              validator: (v) {
                final n = int.tryParse((v ?? '').trim());
                if (n == null || n <= 0) {
                  return 'Masukkan nominal berupa angka lebih dari nol';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Batal'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Simpan')),
      ],
    );
  }
}
