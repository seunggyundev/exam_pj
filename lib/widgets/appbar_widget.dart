
import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/models/evaluation_result.dart';
import 'package:devjang_cs/models/user_model.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/classification_platform.dart';
import 'package:devjang_cs/services/size_calculate.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WebAppBarWidget extends StatefulWidget {
  WebAppBarWidget({Key? key,}) : super(key: key);

  @override
  State<WebAppBarWidget> createState() => _WebAppBarWidgetState();
}

class _WebAppBarWidgetState extends State<WebAppBarWidget> {
  final SizeCalculate _sizeCalculate = SizeCalculate();
  final ColorsModel _colorsModel = ColorsModel();
  User? _client = FirebaseAuth.instance.currentUser;
  UserModel _userModel = UserModel();
  PageProvider _pageProvider = PageProvider();

  @override
  void initState() {
    super.initState();
    userInit();
  }

  // 서버에서 유저정보를 가져옴
  Future<void> userInit() async {
    List resList = await UserServices().getUserModel(uid: AuthService().getUid());
    setState(() {
      _userModel = resList.last;
    });
  }

  @override
  Widget build(BuildContext context) {
    // 가로 사이즈에 따라서 플랫폼 구별
    bool isWeb = ClassificationPlatform().classifyWithScreenSize(context: context) == 2;

    return Consumer<PageProvider> (
        builder: (context, provider, child) {
          double screenSizeWidth = MediaQuery.of(context).size.width;
          double screenSizeHeight = MediaQuery.of(context).size.height;

          return AppBar(
            toolbarHeight: 80,
            elevation: 0,
            backgroundColor: _colorsModel.wh,
            leadingWidth: 150,
            leading: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(top: _sizeCalculate.heightCalculate(screenSizeHeight, 15), left: isWeb ? _sizeCalculate.widthCalculate(screenSizeWidth, 60) : 15),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(
                          onTap: () async {
                            provider.updatePage(0);
                          },
                          child: SizedBox(
                            width: _sizeCalculate.widthCalculate(screenSizeWidth, 90),
                            height: _sizeCalculate.heightCalculate(screenSizeHeight, 47),
                            child: Image.asset('assets/icons/haiLabIcon.png'),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),  // leading은 앱바의 왼쪽을 정의
            actions: [
              Padding(
                padding: EdgeInsets.only(right: isWeb ? _sizeCalculate.widthCalculate(screenSizeWidth, 60) : 15),
                child: actionsWidget(),
              ),
            ],  // actions는 앱바의 오른쪽 영영을 정의
          );
        });
  }

  Widget actionsWidget() {
    return Builder(
      builder: (context) => IconButton(
        icon: const Icon(Icons.menu, size: 30,),
        onPressed: () => Scaffold.of(context).openEndDrawer(), // 오른쪽 Drawer 열기
      ),
    );
  }
}