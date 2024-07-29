// 클래스 생성 기본 구조
// class 클래스명 {
//   // 속성 (멤버 변수)
//   // 생성자
//   // 메서드
// }

// 예시: 간단한 모델 클래스
import 'dart:convert';

class User {
  // 속성 (멤버 변수)
  // 이 클래스는 사용자 정보인 name, age, email을 속성으로 가지고 있습니다.
  // 생성자는 이 속성들을 초기화하며, printInfo 메서드는 사용자 정보를 출력합니다.
  String name;
  int age;
  String email;

  // 생성자
  User({required this.name, required this.age, required this.email});

  // 메서드
  void printInfo() {
    print('Name: $name, Age: $age, Email: $email');
  }
}

// JSON과 상호작용하는 모델 클래스(실무에서 많이 사용)
class UserJson {
  String name;
  int age;
  String email;

  // 생성자
  // required키워드는 사용하지 않는 경우도 많습니다 required를 제거해도 괜찮습니다
  UserJson({required this.name, required this.age, required this.email});

  // JSON 데이터를 User 객체로 변환하는 팩토리 생성자
  factory UserJson.fromJson(Map<String, dynamic> json) {
    return UserJson(
      name: json['name'],
      age: json['age'],
      email: json['email'],
    );
  }

  //위와 동일하지만 표현이 다르게 한다면
  UserJson returnModel(Map<String, dynamic> json) {
    return UserJson(
        name: name,
        age: age,
        email: email
    );
  }

  // User 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'age': age,
      'email': email,
    };
  }
}

// 호출사용예시
void test() {
  // JSON 데이터를 User 객체로 변환
  // 여기서의 jsonString 또는 userMap은 추후에 서버에서 받아올 데이터라고 생각하시면 됩니다
  String jsonString = '{"name": "Alice", "age": 25, "email": "alice@example.com"}';
  Map<String, dynamic> userMap = jsonDecode(jsonString);
  UserJson user = UserJson.fromJson(userMap);

  // 데이터 출력
  print("user name : ${user.name}");
  print("user age : ${user.age}");
  print("user email : ${user.email}");

  // User 객체를 JSON으로 변환
  String json = jsonEncode(user.toJson());
  print(json);
}