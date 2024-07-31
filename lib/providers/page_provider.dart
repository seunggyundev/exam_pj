import 'package:devjang_cs/models/chat_model.dart';
import 'package:flutter/cupertino.dart';

class PageProvider extends ChangeNotifier {

  List _chatEvaluations = [];   // 채팅창이 종료되고 넘어온 데이터
  List get chatEvaluations => _chatEvaluations;

  updateChatEvaluations(List chatEvaluations) {
    _chatEvaluations = chatEvaluations;
    notifyListeners();
  }

  bool _isFromChat = false;  // 채팅창으로부터 넘어오면 UI가 변경됨
  bool get isFromChat => _isFromChat;

  updateIsFromChat(bool isFromChat) {
    _isFromChat = isFromChat;
    notifyListeners();
  }

  bool _isRefresh = false;
  bool get isRefresh => _isRefresh;

  updateIsRefersh(bool isRefresh) {
    _isRefresh = isRefresh;
    notifyListeners();
  }

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