import 'package:devjang_cs/models/colors_model.dart';

class ChatTypeModel {
  var key;  // 해당 키로 채팅데이터를 가져옴
  var explain;  // 해당 타입에 대한 설명

  ChatTypeModel({this.explain, this.key,});

  ChatTypeModel returnModel(Map dataMap) {
    return ChatTypeModel(
      key: dataMap['key'],
      explain: dataMap['explain'],
    );
  }
}