import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/providers/validate_provider.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:devjang_cs/services/validate.dart';
import 'package:devjang_cs/widgets/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class RegistUserPage extends StatefulWidget {
  const RegistUserPage({Key? key}) : super(key: key);

  @override
  State<RegistUserPage> createState() => _RegistUserPageState();
}

class _RegistUserPageState extends State<RegistUserPage> {
  TextEditingController _nmController = TextEditingController();  // 이름 Controller
  TextEditingController _departmentNmController = TextEditingController();  // 학과명 Controller
  TextEditingController _passwordController = TextEditingController();  // 비밀번호 Controller
  TextEditingController _passwordConfirmController = TextEditingController();  // 비밀번호 확인 Controller
  TextEditingController _emailController = TextEditingController();  // 이메일 Controller
  final ColorsModel _colorsModel = ColorsModel();

  ValidateProvider _validateProvider = ValidateProvider();  // 형식 점검을 위한 Provider

  bool _isPasswordShow = false;  // 비밀번호 노출 여부
  bool _isPasswordConfirmShow = false;  // 비밀번호 확인 노출 여부

  FocusNode _emailFocus = FocusNode();  // 이메일 입력필드로 Focus를 주기위해 생성
  FocusNode _passwordFocus = FocusNode();  // 비밀번호 입력필드로 Focus를 주기위해 생성

  bool _loading = false;

  //메모리관리를 위해 Controller들은 dispose필요
  // dispose()는 현재의 class에서 벗어날 때 호출되는 부분이다
  @override
  void dispose() {
    if (mounted) {
      // 현재 위젯 트리에 마운트 되었을 때
      // StstefulWidget의 State객체가 위젯트리에 추가될 때 이를 "마운트 되었다"라고 표현
      _nmController.dispose();
      _departmentNmController.dispose();
      _passwordConfirmController.dispose();
      _passwordController.dispose();
      _emailController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _validateProvider = Provider.of<ValidateProvider>(context, listen: true);

    // 동적으로 가로,세로 사이즈 할당시 사용
    var screenWidth = MediaQuery.of(context).size.width;
    // var screenHeight = MediaQuery.of(context).size.height;

    // 모든 입력값 입력 및 검증되었는지 판단
    bool isAllPass = false;

    if (
    _nmController.text.isNotEmpty &&
        _departmentNmController.text.isNotEmpty &&
        _passwordConfirmController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _validateProvider.emailValidate &&
    _validateProvider.passwordValidate &&
    _validateProvider.passwordConfirmVali
    ) {
      isAllPass = true;
    }

    return GestureDetector(
        onTap: () {
          // 키보드가 팝업됐을 때 배경을 눌러 키보드를 내리게 한다
          FocusManager.instance.primaryFocus?.unfocus();
        },
        child: Scaffold(
          // resizeToAvoidBottomInset: _isResizeBtm,
          backgroundColor: _colorsModel.wh,
          appBar: AppBar(
            toolbarHeight: 48.4,
            elevation: 0,
            backgroundColor: _colorsModel.wh,
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
            title: Text('회원가입', style: TextStyle(fontSize: 16,
                color: _colorsModel.bl),),
            leadingWidth: 40,
            centerTitle: true,
          ),
          body: Stack(
            children: [
              ListView(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      children: [
                        const SizedBox(height: 10,),
                        Text('이름', style: TextStyle(
                          fontSize: 14,
                          color: _colorsModel.gr1,
                        ),),
                        const SizedBox(height: 10,),
                        textFieldWidget(_nmController, '이름 입력해주세요.'),
                        const SizedBox(height: 10,),
                        Text('학과명', style: TextStyle(
                          fontSize: 14,
                          color: _colorsModel.gr1,
                        ),),
                        const SizedBox(height: 10,),
                        textFieldWidget(_departmentNmController, '학과명을 입력해주세요.'),
                        const SizedBox(height: 10,),
                        Text('이메일', style: TextStyle(
                          fontSize: 14,
                          color: _colorsModel.gr1,
                        ),),
                        const SizedBox(height: 10,),
                        textFieldWidget(_emailController, '이메일을 입력해주세요.'),
                        const SizedBox(height: 10,),
                        Text('비밀번호', style: TextStyle(
                          fontSize: 14,
                          color: _colorsModel.gr1,
                        ),),
                        const SizedBox(height: 10,),
                        textFieldWidget(_passwordController, '비밀번호를 입력해주세요.'),
                        Text('비밀번호 확인', style: TextStyle(
                          fontSize: 14,
                          color: _colorsModel.gr1,
                        ),),
                        const SizedBox(height: 10,),
                        textFieldWidget(_passwordConfirmController, '비밀번호를 다시 입력해주세요.'),
                        const SizedBox(height: 50,),
                        GestureDetector(
                          onTap: () async {
                            if (isAllPass) {
                              if (_loading) {
                                // 로딩중에 또 누르면 서버작업이 중복되기에 막음
                                return;
                              }
                              setState(() {
                                _loading = true;
                              });

                              List authResList = await AuthService().signUpWithEmail(email: _emailController.text, password: _passwordController.text, context: context);
                              print('authResList ${authResList}');
                              if (authResList.first) {
                                List userResList = await UserServices().updateUser(uid: authResList[1], email: _emailController.text, pw: _passwordController.text, nm: _nmController.text, departNm: _departmentNmController.text);
                                print('userResList ${userResList}');
                                setState(() {
                                  _loading = false;
                                });
                                if (userResList.first) {
                                  Navigator.pop(context);
                                } else {
                                  Dialogs().onlyContentOneActionDialog(context: context, content: '회원가입 실패\n${userResList.last}', firstText: '확인');
                                }
                              } else {
                                setState(() {
                                  _loading = false;
                                });
                                Dialogs().onlyContentOneActionDialog(context: context, content: '회원가입 실패\n${authResList.last}', firstText: '확인');
                              }
                            } else {
                              Dialogs().onlyContentOneActionDialog(context: context, content: '모든 내용을 입력해주세요', firstText: '확인');
                            }
                          },
                          child: Container(
                            width: screenWidth,
                            decoration: BoxDecoration(
                              color: isAllPass ? _colorsModel.main : _colorsModel.wh,
                              borderRadius: BorderRadius.circular(6),
                              border: Border.all(color: _colorsModel.main),
                            ),
                            child: Center(
                              child: Text(
                                '가입하기',
                                style: TextStyle(
                                  fontSize: 24,
                                  color: isAllPass ? _colorsModel.wh : _colorsModel.main,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 200 + MediaQuery.of(context).viewInsets.bottom,),  // MediaQuery.of(context).viewInsets.bottom를 사용하면 키보드가 올라왔을 때 동적으로 여백을  생성해서 짤리지 않게 한다
                      ],
                    ),
                  ),
                ],
              ),
              _loading ? Center(child: CircularProgressIndicator(color: _colorsModel.main,),) : Container(),
            ],
          )
        ));
  }

  Widget textFieldWidget(
      TextEditingController textEditingController,
      String hintText,
      ) {

    bool _isPassword = false;
    bool _isEye = false;
    bool _isRed = false;
    String _helperText = "";
    int _inputMenu = 0; // 1 : 비밀번호, 2 : 비밀번호 확인

    if (textEditingController == _passwordController || textEditingController == _passwordConfirmController) {
      _isPassword = true;
    }

    if (textEditingController == _passwordConfirmController && _isPasswordConfirmShow) {
      _isEye = true;
    }

    if (textEditingController == _passwordController && _isPasswordShow) {
      _isEye = true;
    }

    if (textEditingController == _passwordController) {
      _inputMenu = 1;
    } else if (textEditingController == _passwordConfirmController) {
      _inputMenu = 2;
    }

    if (textEditingController == _emailController) {
      // or : ||, and : &&
      if (textEditingController.text.isNotEmpty && !_validateProvider.emailValidate) {
        _isRed = true;
        _helperText = '이메일 형식이 맞지않습니다.';
      }

      if (!_validateProvider.isCanUseEmail) {
        _isRed = true;
        _helperText = '이미 존재하는 이메일 입니다.';
      }

      return TextFormField(
        focusNode: _emailFocus,
        textDirection: TextDirection.ltr,
        cursorColor: _colorsModel.main,
        controller: textEditingController,
        onChanged: (text) {
          if (text.isNotEmpty) {
            var inputValue = text.trim();
            var validate = CheckValidate().validateEmail(_emailFocus, inputValue);

            WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
              _validateProvider.updateEmailValidate(validate);  //이메일 형식 점검
            });
          }
          setState(() {

          });
        },
        textInputAction: TextInputAction.next,
        keyboardType: TextInputType.text,
        style: TextStyle(
          color: _colorsModel.bl,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          counterText: '',
          contentPadding: _isPassword ? EdgeInsets.only(right: 50, left: 15) :EdgeInsets.symmetric(vertical: 0, horizontal: 15),
          filled: true,
          fillColor: Colors.transparent,
          hintText: hintText,
          helperText: _isRed ? _helperText  : '',
          hintStyle: TextStyle(fontSize: 16, color: _colorsModel.gr2),
          helperStyle: TextStyle(fontSize: 11, color: _isRed ? _colorsModel.red : _colorsModel.gr2),
          border: InputBorder.none,
          label: _isRed ? SizedBox(
            width: 24,
            height: 24,
            child: Image.asset("assets/icons/warning.png"),
          ) : Container(width: 0, height: 0,),
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
      );
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
          onChanged: (text) {
            if (_inputMenu == 1 && text.isNotEmpty) {
              var inputValue = text.trim();
              WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
                setState(() {
                  _validateProvider.updatePasswordValidate(CheckValidate().validatePassword(
                      _passwordFocus, inputValue));  //비밀번호 형식 점검
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
            setState(() {

            });
          },
          textInputAction: TextInputAction.next,
          keyboardType:  TextInputType.text,
          style: TextStyle(
            color: _colorsModel.bl,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            helperText: _isRed ? _helperText : '',
            counterText: '',
            contentPadding: _isPassword ? EdgeInsets.only(right: 50, left: 15) :EdgeInsets.symmetric(vertical: 0, horizontal: 15),
            filled: true,
            fillColor: Colors.transparent,
            hintText: hintText,
            hintStyle: TextStyle(fontSize: 16, color: _colorsModel.gr2),
            helperStyle: TextStyle(fontSize: 11, color: _isRed ? _colorsModel.red : _colorsModel.gr2),
            border: InputBorder.none,
            label: _isRed ? SizedBox(
              width: 24,
              height: 24,
              child: Image.asset("assets/icons/warning.png"),
            ) : Container(width: 0, height: 0,),
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
            if (textEditingController == _passwordConfirmController) {
              setState(() {
                _isPasswordConfirmShow = !_isPasswordConfirmShow;
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
}
