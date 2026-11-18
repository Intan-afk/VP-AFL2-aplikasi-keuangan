import 'package:flutter/foundation.dart';

import '../core/failure.dart';
import 'error_state.dart';

class ErrorViewModel extends ChangeNotifier {
  ErrorState _state = const NoError();
  bool _disposed = false;

  ErrorState get state => _state;

  void report(Object error) {
    final message = error is Failure
        ? error.message
        : 'Terjadi kesalahan. Silakan coba lagi.';
    _emit(HasError(message));
  }

  void clear() {
    if (_state is NoError) return;
    _emit(const NoError());
  }

  void _emit(ErrorState next) {
    if (_disposed) return;
    _state = next;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
