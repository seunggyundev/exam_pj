import 'package:flutter/material.dart';

class CounterProvider with ChangeNotifier {
  int _count = 0;
  int get count => _count;

  void increment() {
    _count++;
    notifyListeners();
  }

  void setCount(int count) {
    _count = count;
    notifyListeners();
  }
}