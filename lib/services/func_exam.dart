class FuncExam {
  // 반환타입 함수명(매개변수) {
  //   // 함수의 본문
  //   return 반환값;
  // }

  // 예시 1: 기본적인 함수
  String sayHello() {
    return "Hello, Flutter!";
  }

  // 예시 2: 매개변수가 있는 함수
  int add(int a, int b) {
    return a + b;
  }

  // 예시 3: 선택적 매개변수
  String greet(String name, {String greeting = "Hello"}) {
    return "$greeting, $name!";
  }

  // 예시 4: 선택적 매개변수에 필수여부 추가
  String greetRequired(String name, {required String greeting}) {
    return "$greeting, $name!";
  }

  // 예시 4: 화살표 함수 (Arrow Function)
  int multiply(int a, int b) => a * b;

  // 비동기 함수 (Async Function)
  // Flutter에서는 비동기 프로그래밍이 자주 사용됩니다. 비동기 함수는 async 키워드를 사용합니다.
  Future<void> fetchData() async {
    //var response = await http.get('https://api.example.com/data');
    // 데이터 처리 로직
  }
}