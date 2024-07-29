import 'package:flutter/cupertino.dart';

class PageProvider extends ChangeNotifier {
  int _page = 0;
  int get page => _page;

  updatePage(int page) {
    _page = page;
    notifyListeners();
  }
}