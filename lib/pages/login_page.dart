import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/pages/regist_user_page.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:devjang_cs/providers/validate_provider.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/classification_platform.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:devjang_cs/services/validate.dart';
import 'package:devjang_cs/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final ColorsModel _colorsModel = ColorsModel();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _passwordConfirmController = TextEditingController();
  PageProvider _pageProvider = PageProvider();
  ValidateProvider _validateProvider = ValidateProvider();
  ScrollController _scrollController = ScrollController();

  bool _isPasswordShow = false;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _passwordConfirmController = TextEditingController();

    _emailController.addListener(() {
      setState(() {
      });
    });
    _passwordController.addListener(() {
      setState(() {
      });
    });
    _passwordConfirmController.addListener(() {
      setState(() {
      });
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _validateProvider = Provider.of<ValidateProvider>(context, listen: true);
    _pageProvider = Provider.of<PageProvider>(context, listen: true);

    var screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = ClassificationPlatform().classifyWithScreenSize(context: context) == 2;

    return Stack(
      children: [
        ListView(
          controller: _scrollController,
          physics: const ScrollPhysics(),
          children: [
            Padding(
              padding: isWeb ? const EdgeInsets.only(left: 60, right: 60) : const EdgeInsets.only(left: 15, right: 15),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 30,),
                  Text('아이디', style: TextStyle(
                    fontSize: 14,
                    color: _colorsModel.gr1,
                  ),),
                  const SizedBox(height: 10,),
                  textFieldWidget(_emailController, '아이디를 입력해주세요.',),
                  Text('비밀번호', style: TextStyle(
                    fontSize: 14,
                    color: _colorsModel.gr1,
                  ),),
                  const SizedBox(height: 10,),
                  textFieldWidget(_passwordController, '비밀번호를 입력해주세요.',),
                  const SizedBox(height: 10,),
                  GestureDetector(
                    onTap: () async {
                      if (_emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && _validateProvider.passwordValidate) {
                        setState(() {
                          _loading = true;
                        });

                        List authResList = await AuthService().login(email: _emailController.text, password: _passwordController.text);

                        if (authResList.first) {
                          List resList = await UserServices().getUserModel(uid: authResList[1].toString());
                          setState(() {
                            _loading = false;
                          });
                          _pageProvider.updatePage(0);
                        } else {
                          setState(() {
                            _loading = false;
                          });
                          Dialogs().onlyContentOneActionDialog(context: context, content: '로그인 오류\n${authResList.last}', firstText: '확인');
                        }
                      }
                    },
                    child: Container(
                      width: screenWidth,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(36),
                        color: _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty && _validateProvider.passwordValidate ? _colorsModel.main : _colorsModel.main.withOpacity(0.7),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12, bottom: 12),
                        child: Center(
                          child: Text('로그인', style: TextStyle(
                            color: _colorsModel.wh,
                            fontSize: 16,
                          ),),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30,),
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MultiProvider(
                              providers: [
                                ChangeNotifierProvider(create: (_) => ValidateProvider()),
                              ],
                              child: const RegistUserPage()
                          )
                          )
                      );
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('계정이 없으신가요?', style: TextStyle(
                          fontSize: 14,
                          color: _colorsModel.gr2,
                        ),),
                        const SizedBox(width: 8,),
                        Text('회원가입', style: TextStyle(
                            fontSize: 14,
                            color: _colorsModel.main,
                            fontWeight: FontWeight.w600
                        ),),
                      ],
                    ),
                  ),
                  SizedBox(height: 50 + MediaQuery.of(context).viewInsets.bottom,),
                ],
              ),
            ),
          ],
        ),
        _loading ? Center(child: CircularProgressIndicator(color: _colorsModel.main,),) : Container(),
      ],
    );
  }

  Widget textFieldWidget(
      TextEditingController textEditingController,
      String hintText,
      ) {

    bool _isPassword = false;
    bool _isEye = false;
    bool _isRed = false;
    String _helperText = '';

    int _inputMenu = 0; // 1 : 비밀번호, 2 : 비밀번호 확인

    if (textEditingController == _passwordController || textEditingController == _passwordConfirmController) {
      _isPassword = true;
    }

    if (textEditingController == _passwordController && _isPasswordShow) {
      _isEye = true;
    }

    if (textEditingController == _passwordController) {
      _inputMenu = 1;
    } else if (textEditingController == _passwordConfirmController) {
      _inputMenu = 2;
    }

    if (_inputMenu == 1 && !_validateProvider.passwordValidate && _passwordController.text.isNotEmpty) {
      _isRed = true;
      _helperText = '비밀번호 형식이 맞지 않습니다.(12자/영어 소문자,특수문자 포함)';
    } else if (_inputMenu == 2 && !_validateProvider.passwordConfirmVali && _passwordConfirmController.text.isNotEmpty) {
      _isRed = true;
      _helperText = '비밀번호가 일치하지 않습니다.다시 한번 확인해주세요.';
    }

    return Stack(
      alignment: Alignment.centerRight,
      children: [
        TextFormField(
          textDirection: TextDirection.ltr,
          cursorColor: _colorsModel.main,
          controller: textEditingController,
          obscureText: _isPassword && !_isEye ? true : false,
          onFieldSubmitted: (text) {
            _scrollDownBy100Pixels();
          },
          onChanged: (text) {
            if (_inputMenu == 1 && text != null) {
              var inputValue = text;
              if (text.contains(' ')) {
                inputValue = text.replaceAll(' ', '');
              }

              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  _validateProvider.updatePasswordValidate(CheckValidate().validatePassword(
                      FocusNode(), inputValue));  //비밀번호 형식 점검
                });
              });
            }
            if (_inputMenu == 2) {

              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  if (_passwordController.text != text) {
                    _validateProvider.updatePasswordConfirmVali(false);
                  } else {
                    _validateProvider.updatePasswordConfirmVali(true);
                  }
                });
              });
            }
          },
          textInputAction: TextInputAction.next,
          keyboardType: TextInputType.text,
          style: TextStyle(
            color: _colorsModel.bl,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            helperText: _isRed ? _helperText : '',
            label: _isRed ? SizedBox(
              width: 24,
              height: 24,
              child: Image.asset("assets/icons/warning.png"),
            ) : Container(width: 0, height: 0,),
            counterText: '',
            contentPadding: _isPassword ? EdgeInsets.only(right: 50, left: 15) :EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            filled: true,
            fillColor: Colors.transparent,
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 16, color: _colorsModel.gr2),
            helperStyle: TextStyle(
                fontSize: 11,
                color: _isRed ? _colorsModel.red : _colorsModel.gr2),
            border: InputBorder.none,
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _isRed ? _colorsModel.red : _colorsModel.gr3,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(36),
            ),
            focusedErrorBorder: OutlineInputBorder(
              // borderSide: BorderSide.none,
              borderSide: BorderSide(
                color: _isRed ? _colorsModel.red : _colorsModel.gr3,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(36),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _isRed ? _colorsModel.red : _colorsModel.main,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(36),
            ),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _isRed ? _colorsModel.red : _colorsModel.gr3,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(36),
            ),
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: _isRed ? _colorsModel.red : _colorsModel.gr3,
                width: 1,
              ),
              borderRadius: BorderRadius.circular(36),
            ),
          ),
        ),
        _isPassword ? GestureDetector(
          onTap: () {
            if (textEditingController == _passwordController) {
              setState(() {
                _isPasswordShow = !_isPasswordShow;
              });
            }

          },
          child: Padding(
            padding: EdgeInsets.only(right: 15.0, bottom: 27),
            child: SizedBox(
              width: 24,
              height: 24,
              child: _isEye ? Image.asset("assets/icons/eye.png") : Image.asset("assets/icons/eyeSlash.png"),
            ),
          ),
        ) : Container(),
      ],
    );
  }

  _scrollDownBy100Pixels() {
    // 현재 스크롤 위치를 가져옵니다.
    double currentOffset = _scrollController.offset;

    // 현재 위치에서 100 픽셀 아래로 이동합니다.
    _scrollController.animateTo(
      currentOffset + 100,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }
}