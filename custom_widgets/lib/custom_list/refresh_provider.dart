import 'package:flutter/material.dart';

class RefreshProvider extends ChangeNotifier {
  bool needsRefresh = false;

  Future<void> triggerRefresh() async {
    needsRefresh = !needsRefresh;
    notifyListeners();
    await Future.delayed(const Duration(seconds: 1));
  }
}
