import 'package:devjang_cs/models/chat_type_model.dart';
import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/models/user_model.dart';
import 'package:devjang_cs/pages/chat_screen.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/chat_services.dart';
import 'package:devjang_cs/services/user_services.dart';
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
    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.all(15.0),
          // 격자형태의 뷰는 아래의 위젯을 사용
          child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, //1 개의 행에 보여줄 item 개수
                childAspectRatio: 1 / 1, //item 의 가로, 세로의 비율
                mainAxisSpacing: 10, //수평 Padding
                crossAxisSpacing: 30, //수평 Padding
              ),
              itemCount: _types.length,
              itemBuilder: (BuildContext context, int index) {
                return typeWidget(_types[index]);
              }),
        ),
        _loading ? Center(child: CircularProgressIndicator(color: _colorsModel.main,),) : Container(),
      ],
    );
  }

  Widget typeWidget(ChatTypeModel typeModel) {
    return GestureDetector(
      onTap: () {
        // 클릭시 해당 모델의 대화창으로 이동
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ChatScreen(typeModel: typeModel)
            )
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.blueGrey),
        ),
        child: Padding(
          padding: const EdgeInsets.only(top: 15, bottom: 15, left: 10, right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("${typeModel.key ?? ''}", style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),),
              const SizedBox(height: 10,),
              Text("${typeModel.explain ?? ''}", style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),textAlign: TextAlign.center,),
            ],
          ),
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
