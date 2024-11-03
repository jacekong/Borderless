import 'package:flutter/material.dart';

class SnackbarProvider extends ChangeNotifier {
  bool _isSending = false;

  bool get isSending => _isSending;

  void showSendingSnackbar() {
    _isSending = true;
    notifyListeners();
  }

  void hideSnackbar() {
    _isSending = false;
    notifyListeners();
  }
}
