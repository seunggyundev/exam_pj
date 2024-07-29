import 'package:http/http.dart' as http;
import 'package:firebase_database/firebase_database.dart';

class KeyServicse {
  // get gpt key
  Future<List> getGptKey() async {
    try {
      // key는 Types에 저장된 채팅타입의 key
      // Chat/안에 여러개의 대화 타입이 있고 선택한 타입의 prompt를 가져온다
      var dataRef = FirebaseDatabase.instance.ref('apiKey/gpt');
      var dataRes = await dataRef.get();  // DatabaseReference에서 .get()키워드를 사용하여 데이터를 가져옴
      return [true, "${dataRes.value ?? ''}"];
    } catch(e) {
      print('error getPrompt ${e}');
      return [false, e.toString()];
    }
  }
}