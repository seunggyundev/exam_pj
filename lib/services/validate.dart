import 'package:flutter/material.dart';

class CheckValidate{
  //이메일 형식 점검
  bool validateEmail(FocusNode focusNode, String value){
    // print('validateEmail ${value}');
    // print('validateEmail ${value.contains(' ')}');
    if(value.isEmpty){
      focusNode.requestFocus();
      return false;
    }else {
      var pattern = r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
      var regExp = RegExp(pattern);
      if(!regExp.hasMatch(value)){
        focusNode.requestFocus();	//포커스를 해당 textformfield에 맞춘다.
        return false;
      }else{
        return true;
      }
    }
  }

  //비밀번호 형식 점검
  bool validatePassword(FocusNode focusNode, String value){
    if(value.isEmpty){
      focusNode.requestFocus();
      return false;
    }else {
      var pattern = r'^(?=.*\d)(?=.*[$@$!%*#?~^<>,.&+=])[A-Za-z\d$@$!%*#?~^<>,.&+=]{7,12}$';
      RegExp regExp = RegExp(pattern);
      if(!regExp.hasMatch(value)){
        focusNode.requestFocus();
        return false;
      }else{
        return true;
      }
    }
  }
}