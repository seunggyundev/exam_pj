import 'package:devjang_cs/models/chat_type_model.dart';
import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/models/user_model.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/chat_services.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  final ChatTypeModel typeModel; // 프롬프트 및 대화창 탐색을 위한 타입모델
  // 아래와 같이 작성하면 ChatScreen을 호출할 때 반드시 typeModel을 넘겨주도록 할 수 있다
  const ChatScreen({Key? key, required this.typeModel}) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ChatServices _chatServices = ChatServices();
  final ColorsModel _colorsModel = ColorsModel();
  final ScrollController _scrollController = ScrollController();

  PageProvider _pageProvider = PageProvider();
  List<Map<String, dynamic>> _messages = [];
  UserModel _userModel = UserModel();
  String _prompt = "";

  // initState는 현재 코드 클래스 호출시 최초 1회 호출되는 함수이다
  // 현재 코드 페이지를 호출할 때 가장 먼저 작업할 함수들을 넣어주면 된다
  @override
  void initState() {
    super.initState();
    promptInit();
    userInit();
  }

  @override
  Widget build(BuildContext context) {
    _pageProvider = Provider.of<PageProvider>(context, listen: true);

    return GestureDetector(
      onTap: () {
        // 바탕 터치시 키보드를 내리기 위함
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          leadingWidth: 40,
          leading: Padding(
            padding: const EdgeInsets.only(left: 15.0),
            child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset("assets/icons/arrowLeft.png",
                      color: _colorsModel.bl,))),
          ),
          title: Text("${widget.typeModel.key}와 대화하기", style: TextStyle(
            fontSize: 16,
          ),),// widget.을 사용하면 위에 정의한(ChatScreen) 변수를 가져다 쓸 수 있다
        ),
        body: Column(
          children: [
            Expanded(  // Expanded를 써야 ListView가 차지할 크기를 알 수 있기에 사용할 수 있는 크기를 전부 사용하라는 의미
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  return _buildMessage(_messages[index]);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 40, left: 15, right: 15),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      maxLines: null,  // 엔터를 눌러 다음 줄을 생성하기 위함
                      textInputAction: TextInputAction.newline,  // 엔터를 눌러 다음 줄을 생성하기 위함
                      decoration: InputDecoration(
                        hintText: '메세지를 입력해주세요',
                        fillColor: Colors.white,
                        filled: true,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        border: InputBorder.none,
                        disabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _colorsModel.gr3,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        focusedErrorBorder: OutlineInputBorder(
                          // borderSide: BorderSide.none,
                          borderSide: BorderSide(
                            color: _colorsModel.gr3,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _colorsModel.main,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color:  _colorsModel.gr3,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(36),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: _colorsModel.gr3,
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(36),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(Icons.send, color: Colors.blue),
                    onPressed: _sendMessage,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 서버에 저장된 대화기록을 불러오는 함수
  // 이전대화까지 포함하여 GPT API통신시 함께 보낼 수 있다
  Future<void> _loadChatMessages() async {
    List<Map<String, dynamic>> messages = await _chatServices.loadChatMessages(key: widget.typeModel.key, uid: _userModel.uid ?? "");
    print('messages ${messages}');
    setState(() {
      _messages = messages;
      _messages.reversed;  // 뒤집어서 정렬
    });
    _scrollToBottom();
  }

  void _sendMessage() async {
    // 비어있는 값이면 return처리
    if (_controller.text.isEmpty) return;

    String userMessage = _controller.text;

    setState(() {
      _controller.clear();
      _messages.add({
        'role': 'user',  // 사용자가 보낸 메세지의 role은 user
        'content': userMessage,
        'time': DateTime.now().toIso8601String(),
      });
    });

    await _chatServices.saveChatMessage(key: widget.typeModel.key, uid: _userModel.uid ?? "", role: 'user', message:  userMessage);

    final assistantMessage = await _chatServices.getResponse(_messages.map((msg) {
      return {
        'role': msg['role'],
        'content': msg['content'],
      };
    }).toList(), _prompt, _pageProvider.gptKey);

    setState(() {
      _messages.add({
        'role': 'assistant',
        'content': assistantMessage,
        'time': DateTime.now().toIso8601String(),
      });

    });

    await _chatServices.saveChatMessage(key: widget.typeModel.key, uid: _userModel.uid ?? "", role: 'assistant',message:  assistantMessage);

    _scrollToBottom();
  }

  // 유저가 메세지 입력 후 자동으로 아래로 스크롤되게 하여 메세지가 가려지지않도록 함
  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
      }
    });
  }

  // 12:08형태로 보여주기 위해 parsing
  String _formatTime(String time) {
    try {
      String dateString = DateFormat('HH:mm').format(DateTime.parse(time));

      return dateString;
    } catch(e) {
      return '';
    }
  }

  Widget _buildMessage(Map<String, dynamic> message) {

    // 메세지의 주인이 사용자냐 GPT냐를 판단하기 위함
    bool isUser = message['role'] == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,  // 유저면 오른쪽에 배치
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
        padding: const EdgeInsets.all(10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),  // 박스의 최대 폭을 지정
        decoration: BoxDecoration(
          color: isUser ? Colors.yellow[700] : Colors.grey[700],  // 유저면 노란색 말풍선
          borderRadius: BorderRadius.circular(15),
        ),
        child: Column(
          crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,  // 전송자에 따라 위치를 다르게 하기 위함
          children: [
            Text(
              message['content'] ?? "",  // ?? : ??앞의 값이 null이면 물음표 뒤의 값을 리턴
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            SizedBox(height: 5),
            Text(
              message['time'] == null ? "" : _formatTime(message['time']),  // 시간값이 null이면 빈 String을 사용
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  // 서버에서 유저정보를 가져옴
  Future<void> userInit() async {
    List resList = await UserServices().getUserModel(uid: AuthService().getUid());

    if (resList.first) {
      setState(() {
        _userModel = resList.last;
      });
      await _loadChatMessages();
    }
  }

  // 서버에서 프롬프트 로드
  Future<void> promptInit() async {
    List resList = await _chatServices.getPrompt(key: widget.typeModel.key);
    if (resList.first) {
      setState(() {
        _prompt = resList.last;
      });
    }
  }
}
