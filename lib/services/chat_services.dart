import 'dart:convert';
import 'package:devjang_cs/models/chat_model.dart';
import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/models/evaluation_result.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

class ChatServices {
  static const String _baseUrl = 'https://api.openai.com/v1/chat/completions';

  Future<String> getResponse(List<Map<String, dynamic>> messages, String prompt, apiKey) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $apiKey',
        },
        body: jsonEncode({
          'model': 'gpt-4o', // 사용할 모델 ID
          'messages': [
            /// for prompt, 프롬프트는 role이 system, 유저 질문은 user, gpt응답은 assistant
            {'role': 'system', 'content': prompt},
            ...messages
          ],
          'max_tokens': 150, // 선택적 매개변수
          'temperature': 0.6, // 선택적 매개변수
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        return data['choices'][0]['message']['content'].trim();  // 응답 메세지만 추출
      } else {
        throw Exception('Failed to load response');
      }
    } catch(e) {
      print("error getResponse ${e}");
      return '';
    }
  }

  Future<void> saveChatMessage({required String key, required String uid, required String role, required String message}) async {
    try {
      // key는 Types에 저장된 채팅타입의 key
      // Chat/안에 여러개의 대화 타입이 있고 선택한 타입의 대화 기록중 특정 유저의 대화기록만 저장한다
      final databaseRef = FirebaseDatabase.instance.ref('Chat/$key/$uid').push();
      String timestamp = DateTime.now().toIso8601String();  // Timestamp를 데이터베이스에 오류없이 담기위해 String타입으로 변환
      await databaseRef.set({
        'time': timestamp,
        'role': role,
        'content': message,
      });
    } catch(e) {
      print('error saveChatMessage ${e}');
    }
  }

  Future<List<Map<String, dynamic>>> loadChatMessages({required String chatModelKey, required String uid}) async {
    try {
      // key는 Types에 저장된 채팅타입의 key
      // Chat/안에 여러개의 대화 타입이 있고 선택한 타입의 대화 기록중 특정 유저의 대화기록을 가져온다
      final databaseRef = FirebaseDatabase.instance.ref('Chat/$chatModelKey/$uid');
      final snapshot = await databaseRef.get();
      if (snapshot.exists) {
        List<Map<String, dynamic>> messages = [];

        for (var data in snapshot.children) {
          messages.add({
            'time': data.child('time').value ?? "",
            'role': data.child('role').value ?? "",
            'content': data.child('content').value ?? "",
          });
        }
        print('return messages ${messages}');
        return messages;
      } else {
        return [];
      }
    } catch(e) {
      print('error loadChatMessages ${e}');
      return [];
    }
  }

  Future<List> getPrompt({required String key}) async {
    try {
      // key는 Types에 저장된 채팅타입의 key
      // Chat/안에 여러개의 대화 타입이 있고 선택한 타입의 prompt를 가져온다
      var dataRef = FirebaseDatabase.instance.ref('Chat/$key/prompt');
      var dataRes = await dataRef.get();  // DatabaseReference에서 .get()키워드를 사용하여 데이터를 가져옴
      return [true, "${dataRes.value ?? ''}"];
    } catch(e) {
      print('error getPrompt ${e}');
      return [false, e.toString()];
    }
  }

  // 챗봇 평가용 프롬프트
  Future<List> getEvalulatePrompt({required String key}) async {
    try {
      // key는 Types에 저장된 채팅타입의 key
      // Chat/안에 여러개의 대화 타입이 있고 선택한 타입의 prompt를 가져온다
      var dataRef = FirebaseDatabase.instance.ref('Chat/$key/evaluatePrompt');
      var dataRes = await dataRef.get();  // DatabaseReference에서 .get()키워드를 사용하여 데이터를 가져옴
      return [true, "${dataRes.value ?? ''}"];
    } catch(e) {
      print('error getPrompt ${e}');
      return [false, e.toString()];
    }
  }

  // 여러개의 프롬프트타입을 선택하기 위해
  Future<List> getTypeList() async {
    try {
      // 하나의 Chat안에 담지않은 이유는 RDB는 키만 받아올 수 없기에 데이터가 무거워질 수 있어
      // 따로 타입들을 모은 데이터로 관리
      var dataRef = FirebaseDatabase.instance.ref('Types');
      var dataRes = await dataRef.get();  // DatabaseReference에서 .get()키워드를 사용하여 데이터를 가져옴

      Map<String, dynamic> dataMap = !dataRes.exists ? {} : Map<String, dynamic>.from(json.decode(json.encode(dataRes.value)));
      List<ChatModel> types = [];

      if (dataMap.isNotEmpty) {
        List keyList = dataMap.keys.toList();
        for (int i = 0; i < keyList.length; i++) {
          Map infoMap = dataMap[keyList[i]];  // 각 타입에 대한 정보들
          types.add(ChatModel().returnModel(infoMap));
        }
      }

      return [true, types];
    } catch(e) {
      print('error getTypeList ${e}');
      return [false, e.toString()];
    }
  }

  // 대화 종료시 평가
  Future<List> endConversation(String chatModelKey, String uid, String userName, String apiKey,) async {
    try {
      // 대화 로그 불러오기
      List<Map<String, dynamic>> messages = await loadChatMessages(chatModelKey: chatModelKey, uid: uid);

      // 대화 로그를 하나의 텍스트로 합치기
      String context = getChatHistory(messages);

      // 대화 평가 수행
      String result = await evaluateChat(context, apiKey, chatModelKey);

      // 평가 결과 저장
      await saveEvaluationResult(
        uid: uid,
        userName: userName,
        chatModelKey: chatModelKey,
        result: result,
        messages: messages,
      );

      List results = EvaluationResult().returnModels(result);

      return [true, results];
    } catch(e) {
      print('error $e');
      return [false, e.toString()];
    }
  }

  // 대화 기록을 하나의 텍스트로 합치는 함수
  String getChatHistory(List<Map<String, dynamic>> messages) {
    String chatHistory = "";
    for (var message in messages) {
      if (message['role'] == 'user') {
        chatHistory += "User: ${message['content']}\n";
      } else if (message['role'] == 'assistant') {
        chatHistory += "AI: ${message['content']}\n";
      }
    }
    return chatHistory;
  }

  // 대화 평가 수행
  Future<String> evaluateChat(String context, String apiKey, String chatModelKey) async {
    try {
      List resList = await getEvalulatePrompt(key: chatModelKey);
      if (resList.first) {
        String evaluatePrompt = resList.last;
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': 'gpt-4o',
            'messages': [
              {'role': 'system', 'content': evaluatePrompt},
              {'role': 'user', 'content': context}
            ],
            'max_tokens': 150,
            'temperature': 0.6,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(utf8.decode(response.bodyBytes));
          return data['choices'][0]['message']['content'].trim();
        } else {
          throw Exception('Failed to evaluate stress');
        }
      } else {
        print("평가 prompt없음");
       return '';
      }
    } catch (e) {
      print("error evaluateStress ${e}");
      return '';
    }
  }

  // 평가 결과 저장
  Future<void> saveEvaluationResult({
    required String uid,
    required String userName,
    required String chatModelKey,
    required String result,
    required List<Map<String, dynamic>> messages,
  }) async {
    try {
      final databaseRef = FirebaseDatabase.instance.ref('Chat/$chatModelKey/History/$uid').push();
      String timestamp = DateTime.now().toIso8601String();   // RDB는 DateTime을 바로 넣어줄 수 없기에 변환
      await databaseRef.set({
        'uid': uid,
        'user_name': userName,
        'date': timestamp,
        'result': result,
        'chat': messages,   // List<Map<String, dynamic>> 대화 로그
      });
    } catch (e) {
      print('error saveEvaluationResult ${e}');
    }
  }

  // 평과 결과 로드
  Future<List> getEvaluationHistory({
    required String uid,
    required String chatModelKey,
  }) async {
    try {
      final dataRes = await FirebaseDatabase.instance.ref('Chat/$chatModelKey/History/$uid').get();

      Map<String, dynamic> dataMap = !dataRes.exists ? {} : Map<String, dynamic>.from(json.decode(json.encode(dataRes.value)));
      List docIdList = dataMap.keys.toList();
      Map returnMap = {};

      for (int i = 0; i < docIdList.length; i++) {
        Map historyMap = dataMap[docIdList[i]] ?? {};
        DateTime time = DateTime.parse(historyMap['date'] ?? "");
        List evaluationResults = EvaluationResult().returnModels(historyMap['result'] ?? "");
        if (evaluationResults.isNotEmpty) {
          returnMap[time] = {
            'comment' : evaluationResults.first,
            'result': evaluationResults.last,
          };
        }
      }

     return [true, returnMap];
    } catch (e) {
      print('error getEvaluationResult ${e}');
      return [false, e.toString()];
    }
  }
}
