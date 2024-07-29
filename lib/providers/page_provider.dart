import 'package:flutter/cupertino.dart';

class PageProvider extends ChangeNotifier {
  String _gptKey = "";
  String get gptKey => _gptKey;

  updateGptKey(String gptKey) {
    _gptKey = gptKey;
    notifyListeners();
  }

  int _page = 0;
  int get page => _page;

  updatePage(int page) {
    _page = page;
    notifyListeners();
  }
}