import 'package:devjang_cs/models/chat_type_model.dart';
import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/models/user_model.dart';
import 'package:devjang_cs/pages/chat_screen.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/chat_services.dart';
import 'package:devjang_cs/services/classification_platform.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SelectTypePage extends StatefulWidget {
  const SelectTypePage({Key? key}) : super(key: key);

  @override
  State<SelectTypePage> createState() => _SelectTypePageState();
}

class _SelectTypePageState extends State<SelectTypePage> {
  ColorsModel _colorsModel = ColorsModel();
  bool _loading = false;
  List<ChatTypeModel> _types = [];  // 서버에 저장된 타입들을 저장하는 변수

  @override
  void initState() {
    super.initState();
    typesInit();  // 서버에서 타입리스트 로드
  }

  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;

    // 가로 사이즈에 따라서 플랫폼 구별
    bool isWeb = ClassificationPlatform().classifyWithScreenSize(context: context) == 2;

    return Stack(
      children: [
        !isWeb ?
        Column(
          children: [
            const SizedBox(height: 30,),
            Expanded(
              child: ListView.builder(
                  itemCount: _types.length,
              itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.only(left: 60, right: 60, bottom: 30),
                child: typeWidget(_types[index], screenWidth, isWeb),
              );
              }),
            ),
          ],
        )   // 모바일일 경우에 UI
         :
        Padding(
          padding: const EdgeInsets.only(left: 60, right: 60, top: 30, bottom: 30),
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
                childAspectRatio: 3 / 1, //item 의 가로, 세로의 비율
                mainAxisSpacing: 30, //수직 Padding
                crossAxisSpacing: 100, //수평 Padding
              ),
              itemCount: _types.length,
              itemBuilder: (BuildContext context, int index) {

                return typeWidget(_types[index], screenWidth, isWeb);
              }),
        ),  // 웹일 경우의 UI
        _loading ? Center(child: CircularProgressIndicator(color: _colorsModel.main,),) : Container(),
      ],
    );
  }

  Widget typeWidget(ChatTypeModel typeModel, screenWidth, bool isWeb) {

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: _colorsModel.skeyBlue,
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
                typeModel.img == null ? Container(
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
                    typeModel.img,  // 이미지 링크 url
                    key: ValueKey(typeModel.img), // 각 위젯의 고유키 설정
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
                    Text("${typeModel.key ?? ''}", style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),),
                    Text("접속기록 추후 추가", style: TextStyle(
                      fontSize: 13,
                      color: _colorsModel.gr2,
                    ),textAlign: TextAlign.center,),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 10,),
            Text("${typeModel.explain ?? ''}", style: TextStyle(
              fontSize: 16,
              color: _colorsModel.gr2,
            ),textAlign: TextAlign.center,),
            !isWeb ? SizedBox(height: 20,) : const Spacer(),  // 넓힐 수 있는 최대 간격을 넓혀줌
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: GestureDetector(
                onTap: () {
                  // 클릭시 해당 모델의 대화창으로 이동
                  Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => ChatScreen(typeModel: typeModel)
                      )
                  );
                },
                child: MouseRegion( // 마우스를 감지하여 마우스 모양을 띄워줌
                  cursor: SystemMouseCursors.click,
                  child: Container(
                    decoration: BoxDecoration(
                      color: _colorsModel.wh,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Padding(
                    padding: EdgeInsets.only(top: 10, bottom: 10),
                    child: Center(
                      child: Text("Start Chat", style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),),
                    ),),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 서버에서 유저정보를 가져옴
  Future<void> typesInit() async {
    setState(() {
      _loading = true;
    });

    List typesResList = await ChatServices().getTypeList();  // 서버에서 타입리스트 로드

    setState(() {
      _loading = false;
    });

    if (typesResList.first) {
      setState(() {
        _types = typesResList.last;
      });
    }
  }
}
