import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';


class AuthService {
  getUid() {
    // uid를 한 곳에서 관리하고
    // 테스트시에도 효율적이기에 uid는 이 함수를 통해서만 가져온다
    User? _client = FirebaseAuth.instance.currentUser;
    var uid = _client?.uid;

    /// for test
    if (uid == null) {
      uid = 'y4qOdfXHx7g8I3lHf5Esbg7btCw2';
    }

    return uid;
  }

  Future<List> sendResetPasswordEmail(String email) async {
    try {
      await FirebaseAuth.instance.setLanguageCode("ko");  //언어 설정
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return [true];
    } catch(e) {
      print('error sendResetPasswordEmail : ${e}');
      return [false, '${e}'];
    }
  }

  Future<List> login({required String email, required String password,}) async {
    try {
      try {
        UserCredential _cred = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: email, password: password);
        //로그인 성공
        return [true, _cred.user?.uid, _cred.user?.email];
      } on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          //존재하지 않는 이메일
          return [false, '존재하지 않는 이메일입니다.'];
        } else if (e.code == 'wrong-password') {
          //비밀번호 오류
          return [false, '비밀번호 오류'];
        }
      }
      return [false, '로그인 실패'];
    } catch(e) {
      print('error login ${e}');
      return [false, '${e}'];
    }
  }

  Future<List> signUpWithEmail({
    required String email,
    required String password,
    required context,
  }) async {
    try {
      UserCredential _cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password); //이 정보로 회원가입
      //회원가입 성공
      return [true, _cred.user?.uid, _cred.user?.email];
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        print('The supplied auth credential is incorrect, malformed or has expired.');
        return [false, '인증 자격 증명이 잘못되었거나, 형식이 올바르지 않거나, 만료되었음'];
      } else if (e.code == 'weak-password') {
        //비밀번호 보안 강도 문제
        return [false, '비밀번호가 보안에 취약합니다'];
      } else if (e.code == 'email-already-in-use') {
        //이미 존재하는 이메일
        return [false, '이미 존재하는 이메일'];
      }
      return [false, e.toString()];
    } catch (e) {
      print('on FirebaseAuthException catch (');
      return [false, e.toString()];
    }
  }

  Future logoutUser() async {
    await FirebaseAuth.instance.signOut();
  }
}
