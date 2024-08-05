import 'package:devjang_cs/models/chat_model.dart';
import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/models/docs_model.dart';
import 'package:devjang_cs/models/user_model.dart';
import 'package:devjang_cs/pages/chat_screen.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:devjang_cs/services/argument_services.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/chat_services.dart';
import 'package:devjang_cs/services/classification_platform.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:devjang_cs/widgets/pdf_viewer_widget.dart';
import 'package:devjang_cs/widgets/toast_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ArgumentHome extends StatefulWidget {
  const ArgumentHome({Key? key}) : super(key: key);

  @override
  State<ArgumentHome> createState() => _ArgumentHomeState();
}

class _ArgumentHomeState extends State<ArgumentHome> {
  ColorsModel _colorsModel = ColorsModel();
  bool _loading = false;
  PageProvider _pageProvider = PageProvider();
  UserModel _userModel = UserModel();
  List<DocsModel> _docs = [];
  Map _linkedTimeMap = {};    // 접속기록

  @override
  void initState() {
    super.initState();
    userInit();
    dataInit();
  }

  @override
  Widget build(BuildContext context) {
    _pageProvider = Provider.of<PageProvider>(context, listen: true);

    var screenWidth = MediaQuery.of(context).size.width;

    // 가로 사이즈에 따라서 플랫폼 구별
    bool isWeb = ClassificationPlatform().classifyWithScreenSize(context: context) == 2;

    return Stack(
      children: [
        !isWeb ?
        Column(
          children: [
            const SizedBox(height: 30,),
            typeWidget(screenWidth, isWeb),
            const SizedBox(height: 30,),
            Expanded(
              child: ListView.builder(
                  itemCount: _docs.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.only(left: 15, right: 15, bottom: 30),
                      child: docWidget(_docs[index], screenWidth, isWeb),
                    );
                  }),
            ),
          ],
        )   // 모바일일 경우에 UI
            :
        Padding(
          padding: const EdgeInsets.only(left: 60, right: 60, top: 0, bottom: 0),
          child: Column(
            children: [
              typeWidget(screenWidth, isWeb),
              const SizedBox(height: 30,),
              Expanded(
                child: GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
                      childAspectRatio: 3 / 1, //item 의 가로, 세로의 비율
                      mainAxisSpacing: 30, //수직 Padding
                      crossAxisSpacing: 100, //수평 Padding
                    ),
                    itemCount: _docs.length,
                    itemBuilder: (BuildContext context, int index) {

                      return docWidget(_docs[index], screenWidth, isWeb);
                    }),
              ),
            ],
          ),
        ),  // 웹일 경우의 UI
        _loading ? Center(child: CircularProgressIndicator(color: _colorsModel.main,),) : Container(),
      ],
    );
  }

  Widget typeWidget(screenWidth, bool isWeb) {
    ChatModel chatModel = _pageProvider.selectChatModel;

    return Container(
      width: screenWidth * 0.5,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _colorsModel.wh,
        border: Border.all(color: _colorsModel.bl),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                chatModel.img == null ? Container(
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
                    chatModel.img,  // 이미지 링크 url
                    key: ValueKey(chatModel.img), // 각 위젯의 고유키 설정
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
                const SizedBox(width: 10,),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("${chatModel.key ?? ''}", style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),),
                    Text("${_linkedTimeMap[chatModel.key] ?? "${chatModel.key}와 대화해보세요!"}", style: TextStyle(
                      fontSize: 13,
                      color: _colorsModel.gr2,
                    ),textAlign: TextAlign.center,),
                  ],
                ),
                const Spacer(),
              ],
            ),
            const SizedBox(height: 10,),
            Text("${chatModel.explain ?? ''}", style: TextStyle(
              fontSize: 16,
              color: _colorsModel.gr2,
            ),textAlign: TextAlign.center,),
            !isWeb ? const SizedBox(height: 20,) : const Spacer(),  // 넓힐 수 있는 최대 간격을 넓혀줌
          ],
        ),
      ),
    );
  }

  Widget docWidget(DocsModel docsModel, screenWidth, bool isWeb) {

    Color _iconColor = _colorsModel.lightGreen;

    if (docsModel.iconNm == "상") {
      _iconColor = _colorsModel.lightPink;
    } else if (docsModel.iconNm == "중") {
      _iconColor = _colorsModel.lightGreen;
    } else if (docsModel.iconNm == "하") {
      _iconColor = _colorsModel.lightYellow;
    }

    return GestureDetector(
      onTap: () {
        _pageProvider.updateSelectDocsModel(docsModel);
        _pageProvider.updateIsNoteApp(false);
        _pageProvider.updatePage(1);
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: _colorsModel.wh,
            border: Border.all(color: _colorsModel.bl),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                          color: _iconColor,
                          borderRadius: BorderRadius.circular(12)
                      ),
                      width: 50,
                      height: 50,
                      child: Center(
                        child: Text("${docsModel.iconNm}", style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),),
                      ),
                    ),
                    const SizedBox(width: 10,),
                    Text("${docsModel.title ?? ''}", style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),),
                  ],
                ),
                const SizedBox(height: 10,),
                Text("${docsModel.explain ?? ''}", style: TextStyle(
                  fontSize: 16,
                  color: _colorsModel.gr2,
                ),textAlign: TextAlign.center,),
                !isWeb ? const SizedBox(height: 20,) : const Spacer(),  // 넓힐 수 있는 최대 간격을 넓혀줌
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> dataInit() async {
    setState(() {
      _loading = true;
    });

    List resList = await ArgumentServices().getDocs();

    setState(() {
      _loading = false;
    });

    if (resList.first) {
      setState(() {
        _docs = resList.last;
      });
    }
  }

  // 서버에서 유저정보를 가져옴
  Future<void> userInit() async {
    List resList = await UserServices().getUserModel(uid: AuthService().getUid());

    if (resList.first) {
      UserModel userModel = resList.last;
      Map linkedTime = userModel.linkedTime ?? {};
      Map linkedTimeMap = {};
      if (linkedTime.isNotEmpty) {
        List modeList = linkedTime.keys.toList();
        for (int i = 0; i < modeList.length; i++) {
          linkedTimeMap[modeList[i]] = timeDifference(linkedTime[modeList[i]] ?? "");
        }
      }
      setState(() {
        _userModel = userModel;
        _linkedTimeMap = linkedTimeMap;
      });
    }
  }

  String timeDifference(String timestamp) {
    DateTime inputTime = DateTime.parse(timestamp);
    DateTime now = DateTime.now();

    Duration difference = now.difference(inputTime);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}분 전';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}시간 전';
    } else if (difference.inDays < 30) {
      return '${difference.inDays}일 전';
    } else {
      int months = difference.inDays ~/ 30;
      return '${months}개월 전';
    }
  }
}
