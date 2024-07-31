import 'package:devjang_cs/models/chat_model.dart';
import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/models/user_model.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/chat_services.dart';
import 'package:devjang_cs/services/classification_platform.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({Key? key,}) : super(key: key);

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
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // provider를 사용시 초기에는 정보를 바로 못받아오는 경우가 있어서
      // 최초 1회 빌드 후 호출하게 해둠
      promptInit();
      userInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    _pageProvider = Provider.of<PageProvider>(context, listen: true);
    // 가로 사이즈에 따라서 플랫폼 구별
    bool isWeb = ClassificationPlatform().classifyWithScreenSize(context: context) == 2;

    return GestureDetector(
      onTap: () {
        // 바탕 터치시 키보드를 내리기 위함
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Column(
        children: [
          Expanded(  // Expanded를 써야 ListView가 차지할 크기를 알 수 있기에 사용할 수 있는 크기를 전부 사용하라는 의미
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: isWeb ? const EdgeInsets.only(left: 60, right: 60) : const EdgeInsets.only(left: 15, right: 15),
                  child: _buildMessage(_messages[index]),
                );
              },
            ),
          ),
          Padding(
            padding: isWeb ? const EdgeInsets.only(bottom: 40, left: 60, right: 60) : const EdgeInsets.only(bottom: 40, left: 15, right: 15),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    maxLines: null,  // 엔터를 눌러 다음 줄을 생성하기 위함
                    textInputAction: TextInputAction.newline,  // 엔터를 눌러 다음 줄을 생성하기 위함
                    decoration: InputDecoration(
                      suffixIcon: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                          onTap: () {
                            _sendMessage();
                          },
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: SizedBox(
                              width: 24,
                              height: 24,
                              child: Image.asset("assets/icons/send.png"),
                            ),
                          ),
                        ),
                      ),
                      hintText: 'Type a message',
                      fillColor: Colors.white,
                      filled: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      border: InputBorder.none,
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _colorsModel.textInputBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        // borderSide: BorderSide.none,
                        borderSide: BorderSide(
                          color: _colorsModel.textInputBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _colorsModel.main,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color:  _colorsModel.textInputBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: _colorsModel.textInputBorder,
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 서버에 저장된 대화기록을 불러오는 함수
  // 이전대화까지 포함하여 GPT API통신시 함께 보낼 수 있다
  Future<void> _loadChatMessages() async {
    List<Map<String, dynamic>> messages = await _chatServices.loadChatMessages(chatModelKey: _pageProvider.selectChatModel.key, uid: _userModel.uid ?? "");
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

    await _chatServices.saveChatMessage(key: _pageProvider.selectChatModel.key, uid: _userModel.uid ?? "", role: 'user', message:  userMessage);

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
    _scrollToBottom();
    await _chatServices.saveChatMessage(key: _pageProvider.selectChatModel.key, uid: _userModel.uid ?? "", role: 'assistant',message:  assistantMessage);
    if (assistantMessage.contains('토론이 종료되었') || assistantMessage.contains('대화가 종료되었')) {
      ChatServices().endConversation(_pageProvider.selectChatModel.key, _userModel.uid ?? "", _userModel.nm ?? "", _pageProvider.gptKey);
    }
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
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          isUser ? Container() : _pageProvider.selectChatModel.img == null ? Container(
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12)
            ),
            width: 50,
            height: 50,
            child: Image.asset("assets/icons/img.png", fit: BoxFit.cover,),
          ) :
          ClipRRect(
            borderRadius: const BorderRadius.all(Radius.circular(12)), // 곡률 설정
            child: Image.network(
              _pageProvider.selectChatModel.img,  // 이미지 링크 url
              key: ValueKey(_pageProvider.selectChatModel.img), // 각 위젯의 고유키 설정
              fit: BoxFit.cover,  // 비율 유지 꽉 채움
              height: 50,
              width: 50,
              errorBuilder: (context, error, stackTrace) {
                print('img error ${error}');
                // 오류났을 경우의 위젯, 기본 사진으로 설정
                return Container(
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12)
                  ),
                  width: 50,
                  height: 50,
                  child: Image.asset("assets/icons/user.png", fit: BoxFit.cover,),
                );
              },
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            padding: const EdgeInsets.all(10),
            constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.75),  // 박스의 최대 폭을 지정
            decoration: BoxDecoration(
              color: isUser ? _colorsModel.userTextBox : _colorsModel.gptTextBox,  // 유저면 노란색 말풍선
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,  // 전송자에 따라 위치를 다르게 하기 위함
              children: [
                Text(
                  message['content'] ?? "",  // ?? : ??앞의 값이 null이면 물음표 뒤의 값을 리턴
                  style: const TextStyle(color: Colors.black, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
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
    List resList = await _chatServices.getPrompt(key: _pageProvider.selectChatModel.key);
    if (resList.first) {
      setState(() {
        _prompt = resList.last;
      });
    }
  }
}
