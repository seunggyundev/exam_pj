import 'dart:convert';

import 'package:devjang_cs/models/docs_model.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

class ArgumentServices {

  // 노트앱 제출
  Future<List> saveNote({required String key, required String uid, required String contents}) async {
    try {
      final databaseRef = FirebaseDatabase.instance.ref('Chat/AI 튜터 논증 및 글쓰기 챗봇/note/$key/$uid').push();
      String timestamp = DateTime.now().toIso8601String();  // Timestamp를 데이터베이스에 오류없이 담기위해 String타입으로 변환
      await databaseRef.set({
        'time': timestamp,
        'contents': contents,
      });

      return [true];
    } catch(e) {
      print('error saveNote ${e}');
      return [false, e.toString()];
    }
  }


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