import 'package:devjang_cs/models/chat_model.dart';
import 'package:flutter/cupertino.dart';

class PageProvider extends ChangeNotifier {
  ChatModel _selectChatModel = ChatModel();
  ChatModel get selectChatModel => _selectChatModel;

  updateChatModel(ChatModel selectChatModel) {
    _selectChatModel = selectChatModel;
    notifyListeners();
  }

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