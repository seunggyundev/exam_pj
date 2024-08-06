class ConvertStressImg {

  Map symptomImgNmMap = {
    '졸음': '[Symptom]_Drowsiness.png',
    '우울감': '[Symptom]_Depression.png',
    '불안감': '[Symptom]_Anxiety.png',
    '사람들로부터의 고립': '[Symptom]_Isolation_from_others.png',
    '공격성 증가': '[Symptom]_Increased_aggressiveness.png',
    '두통': '[Symptom]_Headache.png',
    '절망감': '[Symptom]_Despair.png',
    '수면 장애':'[Symptom]_Sleep_disorder.png',
    '음식 섭취 증가 또는 감소': '[Symptom]_Increased_or_decreased_food_intake.png',
    '논쟁 경향': '[Symptom]_Tendency_to_debate.png',
    '학업에 대한 무관심': '[Symptom]_Lack_of_interest_in_academic_studies.png',
    '집중 저하': '[Symptom]_Concentration_decline.png',
    '만성 피로': '[Symptom]_Chronic_fatigue.png',
    '복부 통증 등의 소화 문제': '[Symptom]_Digestive_problems_such_as_abdominal_pain..png',
    '손톱 물기': '[Symptom]_Nail_biting.png',
  };

  Map causeImgNmMap = {
    '과제 부담': '[Cause]_Workload.png',
    '학업 부담': '[Cause]_Academic_burden.png',
    '제한된 시간': '[Cause]_Limited_time.png',
    '치열한 경쟁': '[Cause]_Fierce_competition.png',
    '교수님과의 관계': '[Cause]_Relationship_with_professor.png',
    '평가': '[Cause]_Evaluation.png',
    '수업 난이도': '[Cause]_Class_difficulty.png',
    '수업 참여 부담': '[Cause]_Burden_of_class_participation.png',
  };

  Map copingImgNmMap = {
    '감정 표출 및 비밀 공유': '[Coping]_Expressing_emotions_and_sharing_secrets.png',
    '계획 수립 및 수행': '[Coping]_Plan_formulation_and_implementation.png',
    '능동적 대응': '[Coping]_Active_coping.png',
    '종교적 신념': '[Coping]_Religious_beliefs.png',
    '상황에 대한 정보 수집': '[Coping]_Collecting_information_on_the_situation.png',
    '자신에 대한 칭찬': '[Coping]_Self_praise.png',
  };

  String getStressImg(String type, String imgKey) {
    print('imgKey ${imgKey}');
    if (imgKey.contains(',')) {
      List splitList = imgKey.split(',');
      imgKey = splitList.first.toString().trim();
    }
    if (type == 'symptom') {
      return symptomImgNmMap[imgKey] ?? "";
    } else if (type == 'cause') {
      return causeImgNmMap[imgKey] ?? "";
    } else {
      return copingImgNmMap[imgKey] ?? "";
    }
  }
}