import 'package:devjang_cs/models/chat_model.dart';
import 'package:devjang_cs/models/docs_model.dart';
import 'package:flutter/cupertino.dart';

class PageProvider extends ChangeNotifier {
  DocsModel _selectDocsModel = DocsModel();
  DocsModel get selectDocsModel => _selectDocsModel;

  updateSelectDocsModel(DocsModel selectDocsModel) {
    _selectDocsModel = selectDocsModel;
    notifyListeners();
  }

  // String _selectDocNm = "";
  // String get selectDocNm => _selectDocNm;
  //
  // updateSelectDocNm(String selectDocNm) {
  //   _selectDocNm = selectDocNm;
  //   notifyListeners();
  // }

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

  bool _isNoteApp = false;
  bool get isNoteApp => _isNoteApp;

  updateIsNoteApp(bool isNoteApp) {
    _isNoteApp = isNoteApp;
    notifyListeners();
  }

  int _prePage = 0;
  int get prePage => _prePage;

  int _page = 0;
  int get page => _page;

  updatePage(int page) {
    if (_prePage == 5) {
      _prePage = 0;
    } else {
      _prePage = _page;
    }
    _page = page;
    notifyListeners();
  }
}