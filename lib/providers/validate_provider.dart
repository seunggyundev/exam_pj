import 'package:flutter/cupertino.dart';

class ValidateProvider extends ChangeNotifier {
  bool _emailValidate = false;
  bool get emailValidate => _emailValidate;

  bool _passwordValidate = false;
  bool get passwordValidate => _passwordValidate;

  bool _passwordConfirmVali = false;
  bool get passwordConfirmVali => _passwordConfirmVali;

  bool _isCanUseEmail = true;
  bool get isCanUseEmail => _isCanUseEmail;

  updateIsCanUseEmail(bool isCanUseEmail) {
    _isCanUseEmail = isCanUseEmail;
    notifyListeners();
  }

  updatePasswordConfirmVali(bool passwordConfirmVali) {
    _passwordConfirmVali = passwordConfirmVali;
    notifyListeners();
  }

  updateEmailValidate(bool emailValidate) {
    _emailValidate = emailValidate;
    notifyListeners();
  }

  updatePasswordValidate(bool passwordValidate) {
    _passwordValidate = passwordValidate;
    notifyListeners();
  }
}