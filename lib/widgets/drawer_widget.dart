import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/models/user_model.dart';
import 'package:devjang_cs/pages/login_page.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:devjang_cs/providers/validate_provider.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/classification_platform.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:devjang_cs/widgets/dialogs.dart';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget({Key? key}) : super(key: key);

  @override
  State<DrawerWidget> createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget> {
  ColorsModel _colorsModel = ColorsModel();
  PageProvider _pageProvider = PageProvider();
  UserModel _userModel = UserModel();

  @override
  void initState() {
    super.initState();
    userInit();
  }

  @override
  Widget build(BuildContext context) {
    _pageProvider = Provider.of<PageProvider>(context, listen: true);
    var screenWidth = MediaQuery.of(context).size.width;
    // 가로 사이즈에 따라서 플랫폼 구별
    bool isWeb = ClassificationPlatform().classifyWithScreenSize(context: context) == 2;

    return Drawer( // 오른쪽 사이드 메뉴 Drawer
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.zero,
      ),
      backgroundColor: _colorsModel.wh,
      width: isWeb ? screenWidth * 0.2 : screenWidth * 0.4,
      child: ListView(
        padding: EdgeInsets.zero,
        physics: const ScrollPhysics(),
        children: [
          const SizedBox(height: 30,),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 15, top: 15),
                child: SizedBox(
                    width: 30,
                    height: 30,
                    child: Image.asset("assets/icons/cancel.png", color: _colorsModel.bl,)),
              ),
            ),
          ),
          ListTile(
            trailing: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Text('Home', style: TextStyle(
                color: _colorsModel.bl,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            ),
            onTap: () async {
              _pageProvider.updatePage(0);
              Navigator.pop(context);
            },
          ),
          ListTile(
            trailing: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Text('HAI Lab', style: TextStyle(
                color: _colorsModel.bl,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            trailing: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Text('Credit', style: TextStyle(
                color: _colorsModel.bl,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            ),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          _userModel.uid != null ? ListTile(
            trailing: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Text('로그아웃', style: TextStyle(
                color: _colorsModel.bl,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            ),
            onTap: () async {
              bool isYes = await Dialogs().yesOrNoDialog(context: context, title: '로그아웃', content: '로그아웃하시겠습니까?');
              if (isYes) {
                await AuthService().logoutUser();
                setState(() {
                  _userModel = UserModel();
                });
              }
              _pageProvider.updateIsRefersh(true);
              Navigator.of(context).pop();
            },
          ) : ListTile(
            trailing: Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: Text('로그인', style: TextStyle(
                color: _colorsModel.bl,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),),
            ),
            onTap: () {
              _pageProvider.updatePage(3);
            },
          ),
        ],
      ),
    );
  }

  // 서버에서 유저정보를 가져옴
  Future<void> userInit() async {
    List resList = await UserServices().getUserModel(uid: AuthService().getUid());
    setState(() {
      _userModel = resList.last;
    });
  }

}
