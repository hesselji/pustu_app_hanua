import 'package:flutter/material.dart';

class ServiceStatus extends ChangeNotifier {
  bool _isAvailable = true;

  bool get isAvailable => _isAvailable;

  void toggleStatus(bool value) {
    _isAvailable = value;
    notifyListeners();
  }
}