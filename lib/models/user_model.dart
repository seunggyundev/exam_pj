// JSON과 상호작용하는 모델 클래스(실무에서 많이 사용)
class UserModel {
  var uid;
  var email;
  var pw;
  var nm;
  var departNm;
  var linkedTime;

  // 생성자
  UserModel({this.uid, this.email, this.departNm, this.nm, this.pw, this.linkedTime});

  // JSON 데이터를 User 객체로 변환하는 팩토리 생성자
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'],
      email: json['email'],
      pw: json['pw'],
      nm: json['nm'],
      departNm: json['departNm'],
        linkedTime: json['linkedTime'],
    );
  }

  // User 객체를 JSON으로 변환하는 메서드
  Map<String, dynamic> toJson(UserModel userModel) {
    return {
      'uid': userModel.uid,
      'email': userModel.email,
      'pw': userModel.pw,
      'nm': userModel.nm,
      'departNm': userModel.departNm,
      'linkedTime': userModel.linkedTime,
    };
  }
}