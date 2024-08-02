import 'dart:convert';

import 'package:devjang_cs/models/docs_model.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

class ArgumentServices {
  // 읽기자료 로드
  Future<List> getDocs() async {
    try {
      final dataRes = await FirebaseDatabase.instance.ref('Chat/AI 튜터 논증 및 글쓰기 챗봇/docs').get();

      Map<String, dynamic> dataMap = !dataRes.exists ? {} : Map<String, dynamic>.from(json.decode(json.encode(dataRes.value)));
      List keyList = dataMap.keys.toList();
      List<DocsModel> docs = [];

      for (int i = 0; i < keyList.length; i++) {
        Map docMap = dataMap[keyList[i]] ?? {};
        docs.add(DocsModel().returnModel(docMap));
      }

      return [true, docs];
    } catch (e) {
      print('error getEvaluationResult ${e}');
      return [false, e.toString()];
    }
  }
}