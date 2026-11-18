import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'data/transaction_repository_impl.dart';
import 'data/transaction_service.dart';
import 'domain/transaction_repository.dart';
import 'viewmodels/error_viewmodel.dart';
import 'viewmodels/transaction_viewmodel.dart';
import 'view/transaction_view.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  final TransactionService service = LocalTransactionService(
    prefs,
    assetPath: 'assets/data/transactions.json',
  );

  final TransactionRepository repository = TransactionRepositoryImpl(service);
  runApp(MyApp(repository: repository));
}

class MyApp extends StatefulWidget {
  final TransactionRepository repository;
  const MyApp({super.key, required this.repository});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final ErrorViewModel _errorViewModel;
  late final TransactionViewModel _transactionViewModel;

  @override
  void initState() {
    super.initState();
    _errorViewModel = ErrorViewModel();
    _transactionViewModel = TransactionViewModel(
      repository: widget.repository,
      errorViewModel: _errorViewModel,
    )..load();
  }

  @override
  void dispose() {
    _transactionViewModel.dispose();
    _errorViewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pencatat Keuangan',
      theme: ThemeData(colorSchemeSeed: Colors.teal, useMaterial3: true),
      home: TransactionView(
        transactionViewModel: _transactionViewModel,
        errorViewModel: _errorViewModel,
      ),
    );
  }
}