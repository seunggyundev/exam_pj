import 'dart:convert';

import 'package:devjang_cs/models/user_model.dart';
import 'package:firebase_database/firebase_database.dart';

class UserServices {

  // 접속기록
  Future<void> updateLinkedTime({required uid, required String chatModelKey}) async {
    try {
      if (uid == null) {
        print('updateLinkedTime uid is null');
        return;
      }
      // User컬렉션에 고유값인 uid를 키로 사용하여 유저데이터를 저장
      var dataRef = FirebaseDatabase.instance.ref('User/${uid}/linkedTime');
      var dataRes = await dataRef.get();  // DatabaseReference에서 .get()키워드를 사용하여 데이터를 가져옴
      var userData = dataRes.value;  // nullable

      Map<String, dynamic> linkedTime = !dataRes.exists ? {} : Map<String, dynamic>.from(json.decode(json.encode(userData)));
      linkedTime['${chatModelKey}'] = DateTime.now().toIso8601String();  //  접속기록
      print('linkedTime ${linkedTime}');
      if (dataRes.exists) {
        // 데이터가 존재하면 업데이트
        await dataRef.update(linkedTime);
      } else {
        // 존재하지 않으면 set
        // 존재하지 않는데 update하면 값 반영안됨 따라서 분기처리 필요
        await dataRef.set(linkedTime);
      }
    } catch(e) {
      print('error updateLinkedTime');
    }
  }

  Future<List> getUserModel({required uid}) async {
    try {
      var dataRef = FirebaseDatabase.instance.ref('User/${uid}');
      var dataRes = await dataRef.get();  // DatabaseReference에서 .get()키워드를 사용하여 데이터를 가져옴

      Map<String, dynamic> userDataMap = !dataRes.exists ? {} : Map<String, dynamic>.from(json.decode(json.encode(dataRes.value)));

      return [true, UserModel.fromJson(userDataMap)];
    } catch(e) {
      print('error getUserModel ${e}');
      return [false, e.toString()];
    }
  }

  Future<List> updateUser({
    required String uid,
    required String email,
    required String pw,
    required String nm,
    required String departNm,
  }) async {
    try {
      // User컬렉션에 고유값인 uid를 키로 사용하여 유저데이터를 저장
      var dataRef = FirebaseDatabase.instance.ref('User/${uid}');
      var dataRes = await dataRef.get();  // DatabaseReference에서 .get()키워드를 사용하여 데이터를 가져옴
      var userData = dataRes.value;  // nullable

      // 데이터가 없으면 빈값을 할당
      // Map<String, dynamic>.from(json.decode(json.encode(userData))) : 데이터타입변환을 위함, 가끔 안하면 에러가 뜨기에 해뒀음
      Map<String, dynamic> userDataMap = !dataRes.exists ? {} : Map<String, dynamic>.from(json.decode(json.encode(userData)));

      userDataMap['uid'] = uid;
      userDataMap['email'] = email;
      userDataMap['pw'] = pw;
      userDataMap['nm'] = nm;
      userDataMap['departNm'] = departNm;

      if (dataRes.exists) {
        // 데이터가 존재하면 업데이트
        await dataRef.update(userDataMap);
      } else {
        // 존재하지 않으면 set
        // 존재하지 않는데 update하면 값 반영안됨 따라서 분기처리 필요
        await dataRef.set(userDataMap);
      }

      return [true, UserModel.fromJson(userDataMap)];
    } catch(e) {
      print('error addUserToDB');
      return [false, e.toString()];
    }
  }

}