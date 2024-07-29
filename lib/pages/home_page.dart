import 'package:devjang_cs/models/user_model.dart';
import 'package:devjang_cs/pages/chat_screen.dart';
import 'package:devjang_cs/pages/login_page.dart';
import 'package:devjang_cs/pages/select_type_page.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:devjang_cs/providers/validate_provider.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/key_services.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:devjang_cs/widgets/appbar_widget.dart';
import 'package:devjang_cs/widgets/dialogs.dart';
import 'package:devjang_cs/widgets/drawer_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool _loading = false;
  UserModel _userModel = UserModel();
  PageProvider _pageProvider = PageProvider();

  // 이 클래스의 접근시 최초 1회 호출됨
  @override
  void initState() {
    super.initState();
    keyInit();
    userInit();
  }

  keyInit() async {
    List resList = await KeyServicse().getGptKey();
    if (resList.first) {
      _pageProvider.updateGptKey(resList.last);
    }
  }

  @override
  Widget build(BuildContext context) {
    _pageProvider = Provider.of<PageProvider>(context, listen: true);

    print('V.13');
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: WebAppBarWidget(),
        ),  // appbar 정의
        endDrawer: const DrawerWidget(),  // 오른쪽 메뉴바가 펼쳐졌을 경우의 위젯
        body: Stack(
          children: [
            bodyChange(),
            _loading ? const Center(child: CircularProgressIndicator(color: Colors.blueGrey,),) : Container(),
          ],
        ),
      ),
    );
  }


  // provider로 body만 바꿔주며 페이지 이동을 위함
  // 그래야 한 화면에서 다루는듯한 느낌이 들어 자연스러움
  bodyChange() {
    if (_userModel.uid != null) {
      if (_pageProvider.page == 0) {
        // 챗봇 선택 페이지
        return const SelectTypePage();
      } else if (_pageProvider.page == 1) {
        // chat screen
        return const ChatScreen();
      }
      return Container();
    } else {
      // 유저정보가 없으면 회원가입 버튼을 아니면 채팅 타입선택창을 띄움
      return MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => ValidateProvider()),
          ],
          child: const LoginPage());
    }
  }

  // 서버에서 유저정보를 가져옴
  Future<void> userInit() async {
    setState(() {
      _loading = true;
    });
    List resList = await UserServices().getUserModel(uid: AuthService().getUid());
    setState(() {
      _userModel = resList.last;
      _loading = false;
    });
  }
}
