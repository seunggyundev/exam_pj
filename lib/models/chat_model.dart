// RDB에서 "Types"안에 Map 타입으로 정보저장
// Types : {"typeNm" : {"key", "explain", "img"}}
// img는 Firebase의 Storage에 파일 업로드 후 해당 파일의 링크를 복사하여 RDB에 붙여넣는 형식
// Storage의 규칙탭을 눌러 아래와 같이 규칙수정 필요
// rules_version = '2';
// service firebase.storage {
//   match /b/{bucket}/o {
//     match /{allPaths=**} {
//       allow read, write: if request.auth != null;
//     }
//   }
// }
// 이후 cors이슈로 이미지 로드가 안되기 때문에 다음의 블로그글을 참고하여 해결 : https://devjang2743.tistory.com/37
class ChatModel {
  var key;  // 해당 키로 채팅데이터를 가져옴
  var explain;  // 해당 타입에 대한 설명
  var img;  // image

  ChatModel({this.explain, this.key, this.img,});

  ChatModel returnModel(Map dataMap) {
    return ChatModel(
      key: dataMap['key'],
      explain: dataMap['explain'],
      img: dataMap['img'],
    );
  }
}