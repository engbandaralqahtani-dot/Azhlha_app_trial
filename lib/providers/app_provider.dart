import 'package:flutter/material.dart';

class AppProvider extends ChangeNotifier {
  int _currentIndex = 0;
  String? _selectedServiceId;
  Map<String, dynamic>? _activeOrder;

  int get currentIndex => _currentIndex;
  String? get selectedServiceId => _selectedServiceId;
  Map<String, dynamic>? get activeOrder => _activeOrder;

  void setCurrentIndex(int index) {
    _currentIndex = index;
    notifyListeners();
  }

  void setSelectedService(String id) {
    _selectedServiceId = id;
    notifyListeners();
  }

  void setActiveOrder(Map<String, dynamic> order) {
    _activeOrder = order;
    notifyListeners();
  }

  void clearActiveOrder() {
    _activeOrder = null;
    notifyListeners();
  }
}
