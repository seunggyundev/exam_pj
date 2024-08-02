import 'dart:ui';

import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/models/debate_result.dart';
import 'package:devjang_cs/models/stress_result.dart';
import 'package:devjang_cs/models/user_model.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/chat_services.dart';
import 'package:devjang_cs/services/classification_platform.dart';
import 'package:devjang_cs/services/size_calculate.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:devjang_cs/widgets/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';

class StressHistoryPage extends StatefulWidget {
  const StressHistoryPage({Key? key}) : super(key: key);

  @override
  State<StressHistoryPage> createState() => _StressHistoryPageState();
}

class _StressHistoryPageState extends State<StressHistoryPage> {

  PageProvider _pageProvider = PageProvider();
  final ColorsModel _colorsModel = ColorsModel();
  UserModel _userModel = UserModel();
  Map _historyMap = {};  // {Datetime time : StressResult()}
  DateTime? _recentTime;
  DateTime? _selectTime;
  List<StressResult> _results = [];
  StressResult _recentResult = StressResult();
  bool _loading = false;
  String _averageStressDescription = "";
  double _averageScore = 0.0;

  // initState는 현재 코드 클래스 호출시 최초 1회 호출되는 함수이다
  // 현재 코드 페이지를 호출할 때 가장 먼저 작업할 함수들을 넣어주면 된다
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // provider를 사용시 초기에는 정보를 바로 못받아오는 경우가 있어서
      // 최초 1회 빌드 후 호출하게 해둠
      dataInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    _pageProvider = Provider.of<PageProvider>(context, listen: true);

    var screenWidth = MediaQuery.of(context).size.width;
    var screenHeight = MediaQuery.of(context).size.height;

    // 가로 사이즈에 따라서 플랫폼 구별
    bool isWeb = ClassificationPlatform().classifyWithScreenSize(context: context) == 2;

    return Stack(
      children: [
        ListView(
          children: [
            const SizedBox(height: 15,),
            _recentResult.scores == null ? Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Text("아직 대화 기록이 없습니다", style: TextStyle(
                  fontSize: 16,
                  color: _colorsModel.gr1,
                ),),
              ),
            ) : Column(
              children: [
                SizedBox(height: 8),
                recentStressWidget(screenWidth, screenHeight, isWeb),
                historyWidget(screenWidth, screenHeight, isWeb),
              ],
            ),
          ],
        ),
        _loading ? Center(child: CircularProgressIndicator(color: _colorsModel.main,),) : Container()
      ],
    );
  }

  Widget historyWidget(screenWidth, screenHeight, isWeb) {
    return Padding(
      padding: isWeb ? const EdgeInsets.only(left: 60, right: 60) : const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20,),
          Container(
            width: screenWidth,
            decoration: BoxDecoration(
              color: _colorsModel.userTextBox,
              border: Border.all(color: _colorsModel.bl),
            ),
            child: const Padding(
              padding: EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text("지난 결과 조회", style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),),
              ),
            ),
          ),
          const SizedBox(height: 20,),
          selectDateWidget(screenWidth, isWeb),
          const SizedBox(height: 60),

        ],
      ),
    );
  }

  Widget recentStressWidget(screenWidth, screenHeight, isWeb) {
    Color averageColor = Colors.black;

    double stressImageWidth = SizeCalculate().widthCalculate(screenWidth, 402);
    double arrowPadding = 0.0;

    if (_averageScore >= 4.5) {
      averageColor = _colorsModel.red;
      arrowPadding = 10;
    } else if (_averageScore >= 3.5) {
      averageColor = Colors.orange;
      arrowPadding = stressImageWidth / 3 - 10;
    } else if (_averageScore >= 2.5) {
      averageColor = Colors.yellow;
      arrowPadding = (stressImageWidth / 3) * 2 - 30;
    } else {
      averageColor = Colors.green;
      arrowPadding = (stressImageWidth / 3) * 2.65;
    }

    Map groupDetails = groupDetailsByCategory(_recentResult.scores ?? []);

    return Padding(
      padding: isWeb ? const EdgeInsets.only(left: 60, right: 60) : const EdgeInsets.only(left: 15, right: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20,),
          Container(
            width: screenWidth,
            decoration: BoxDecoration(
              color: _colorsModel.userTextBox,
              border: Border.all(color: _colorsModel.bl),
            ),
            child: Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              child: Center(
                child: Text("${_userModel.nm ?? ""}님의 학업 스트레스", style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),),
              ),
            ),
          ),
          const SizedBox(height: 20,),
          Text("${_recentTime?.month}월 ${_recentTime?.day}일 ${_userModel.nm ?? ""}님의 학업 스트레스는 ...", style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),),
          const SizedBox(height: 15,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Stack(
                alignment: Alignment.bottomLeft,
                children: [
                  Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 30, right: 30),
                        child: SizedBox(
                          width: stressImageWidth,
                          height: SizeCalculate().heightCalculate(screenHeight, 208),
                          child: Image.asset("assets/icons/stress.png"),
                        ),
                      ),
                      SizedBox(height: SizeCalculate().heightCalculate(screenHeight, 70),),
                    ],
                  ),
                  Padding(
                      padding: EdgeInsets.only(left: arrowPadding),
                      child: SizedBox(
                        width: SizeCalculate().widthCalculate(screenWidth, 99),
                        height: SizeCalculate().heightCalculate(screenHeight, 100),
                        child: Image.asset("assets/icons/arrowRed.png"),
                      ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(left: 15, bottom: 50),
                child: RichText(
                    text: TextSpan(
                        children: [
                          TextSpan(text: '${_averageStressDescription} 정도',
                            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: averageColor),),
                          const TextSpan(text: '의  스트레스를 겪고 있어요!', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, )),
                        ])
                ),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          isWeb? Row(
            children: [
              categoryWidget(
                detail: groupDetails['스트레스 원인'],
                isWeb: isWeb,
                screenWidth: screenWidth,
              ),
              symptomWidget(detail: groupDetails['스트레스 증상'], isWeb: isWeb, screenWidth: screenWidth),
              solutionWidget(detail: groupDetails['대처 방안'], isWeb: isWeb, screenWidth: screenWidth),
            ],
          ) : Column(
            children: [
              categoryWidget(
                detail: groupDetails['스트레스 원인'],
                isWeb: isWeb,
                screenWidth: screenWidth,
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text("AI의 요약", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            _recentResult.summary,
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
          const Text("AI의 피드백", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Text(
            _recentResult.feedback,
            style: TextStyle(fontSize: 18, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 60),
        ],
      ),
    );
  }

  Widget categoryWidget({
    required String detail,
    required bool isWeb,
    required screenWidth,
  }) {

    return Padding(
      padding: isWeb ? const EdgeInsets.only(left: 60, right: 60, bottom: 30) : const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: Container(
        width: screenWidth * 0.2,
        decoration: BoxDecoration(
          color: _colorsModel.gr4,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding:  const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          child: Column(
            children: [
              Container(
                width: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: _colorsModel.titleBox,
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Center(
                    child: Text("스트레스 원인", style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              SizedBox(
                width: screenWidth * 0.2,
                height: 156,
                child: Image.asset("assets/icons/board.png"),
              ),
              const SizedBox(height: 15,),
              SizedBox(
                width: screenWidth * 0.4,
                child: Text(
                  detail.isEmpty ? "많은 어려움을 겪고있지 않아요" :
                  "${detail}으로 인해 어려움을 겪고있어요", style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget symptomWidget({
    required String detail,
    required bool isWeb,
    required screenWidth,
}) {

    return Padding(
      padding: isWeb ? const EdgeInsets.only(left: 60, right: 60, bottom: 30) : const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: Container(
        width: screenWidth * 0.2,
        decoration: BoxDecoration(
          color: _colorsModel.gr4,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding:  const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          child: Column(
            children: [
              Container(
                width: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: _colorsModel.titleBox,
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Center(
                    child: Text("스트레스 증상", style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              SizedBox(
                width: screenWidth * 0.2,
                height: 156,
                child: Image.asset("assets/icons/headache.png"),
              ),
              const SizedBox(height: 15,),
              SizedBox(
                width: screenWidth * 0.4,
                child: Text(
                  detail.isEmpty ? "스트레스 증상을 겪고있지 않아요" :
                  "$detail의 증상을 겪고 있어요", style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget solutionWidget({
    required String detail,
    required bool isWeb,
    required screenWidth,
  }) {

    return Padding(
      padding: isWeb ? const EdgeInsets.only(left: 60, right: 60, bottom: 30) : const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: Container(
        width: screenWidth * 0.2,
        decoration: BoxDecoration(
          color: _colorsModel.gr4,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              spreadRadius: 2,
              blurRadius: 4,
              offset: const Offset(0, 1), // changes position of shadow
            ),
          ],
        ),
        child: Padding(
          padding:  const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          child: Column(
            children: [
              Container(
                width: screenWidth * 0.2,
                decoration: BoxDecoration(
                  color: _colorsModel.titleBox,
                ),
                child: const Padding(
                  padding: EdgeInsets.only(top: 10, bottom: 10),
                  child: Center(
                    child: Text("대처 방안", style: TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),),
                  ),
                ),
              ),
              const SizedBox(height: 15,),
              SizedBox(
                width: screenWidth * 0.2,
                height: 156,
                child: Image.asset("assets/icons/friends.png"),
              ),
              const SizedBox(height: 15,),
              SizedBox(
                width: screenWidth * 0.4,
                child: Text(
                  detail.isEmpty ? "관련된 대처 방안을 찾지 못했어요" :
                  "$detail에 대해 고민해보면 어떨까요?", style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black,
                ),),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget selectDateWidget(screenWidth, isWeb) {
    bool _isExpanded = false;
    return StatefulBuilder(builder: (BuildContext context, stateSetter) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("날짜 선택", style: TextStyle(
            fontSize: 14,
            color: _colorsModel.gr1,
          ),),
          const SizedBox(height: 5,),
          Container(
            height: 60,
            width: screenWidth,
            decoration: BoxDecoration(
              color:  Colors.white,
              border: Border.all(color: _colorsModel.gr3, width: 1),
              borderRadius: _isExpanded ? const BorderRadius.only(
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(8)
              ) : const BorderRadius.all(Radius.circular(8)),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton2(
                selectedItemHighlightColor: _colorsModel.selectedBoxColor,
                itemHighlightColor: _colorsModel.main.withOpacity(0.7),
                buttonDecoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: _isExpanded ? const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8)
                  ) : const BorderRadius.all(Radius.circular(8)),
                ),
                icon: Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: Image.asset("assets/icons/caret_down.png"),
                  ),
                ),
                itemPadding: EdgeInsets.only(left: 0),
                dropdownMaxHeight: 200,
                onMenuStateChange: (changed) {
                  stateSetter(() {
                    _isExpanded = changed;
                  });
                },
                dropdownDecoration: BoxDecoration(
                  borderRadius: BorderRadius.only(bottomRight: Radius.circular(8), bottomLeft: Radius.circular(8)),
                  color: _colorsModel.wh,
                ),
                hint: Container(
                  height: 50,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 15.0),
                      child: Text(
                        '날짜를 선택해주세요',
                        style: TextStyle(
                          fontSize: 16,
                          color: _colorsModel.gr1,
                        ),
                      ),
                    ),
                  ),
                ),
                items: _historyMap.keys.toList()
                    .map((item) => DropdownMenuItem<DateTime>(
                  value: item,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: FittedBox(
                      child: Text(
                        '${formatDateTime(item)}',
                        style: TextStyle(
                          fontSize: 16,
                          color: _colorsModel.gr1,
                        ),
                      ),
                    ),
                  ),
                ))
                    .toList(),
                value: _selectTime,
                onChanged: (value) {
                  setState(() {
                    _selectTime = value;
                  });
                },
                buttonHeight: 40,
                buttonWidth: 90,
                itemHeight: 40,
              ),
            ),
          ),
        ],
      );
    });
  }

  Future<void> dataInit() async {
    try {
      setState(() {
        _loading = true;
      });

      List resList = await UserServices().getUserModel(uid: AuthService().getUid());

      if (resList.first) {
        setState(() {
          _userModel = resList.last;
        });

        List historyResList = await ChatServices().getStressHistory(uid: _userModel.uid, chatModelKey: _pageProvider.selectChatModel.key);
        if (historyResList.first) {
          Map historyMap = historyResList.last; // {Datetime time : StressResult(

          // 키인 Datetime을 리스트로 변환하여 정렬
          List timeList = historyMap.keys.toList();
          timeList.sort((a, b) => b.compareTo(a)); // 최신순으로 정렬

          // 정렬된 시간 리스트를 이용하여 새로운 Map 생성
          Map<DateTime, StressResult> tempHistoryMap = {};
          for (DateTime time in timeList) {
            tempHistoryMap[time] = historyMap[time];
          }

          // 기존 historyMap을 정렬된 tempHistoryMap으로 대체
          historyMap = tempHistoryMap;

          DateTime? recentTime;
          DateTime? selectTime;

          StressResult recentResult = StressResult();
          List<StressResult> results = [];
          double averageScore = 0.0;
          String averageStressDescription = "";

          if (historyMap.isNotEmpty) {
            List timeList = historyMap.keys.toList();

            if (timeList.length > 1) {
              selectTime = timeList[1];
            }

            recentTime = timeList.first;
            recentResult = historyMap[recentTime] ?? StressResult();
            List<int> scores = List<int>.from(recentResult.scores);
            averageScore = scores.reduce((a, b) => a + b) / scores.length;
            averageStressDescription = getAverageStressDescription(averageScore);

            for (int i = 1; i < timeList.length; i++) {
              DateTime time = timeList[i];
              if (time != recentTime) {
                results.add(historyMap[time]);
              }
            }
          }

          historyMap.remove(recentTime);

          setState(() {
            _recentTime = recentTime;
            _historyMap = historyMap;
            _selectTime = selectTime;
            _recentResult = recentResult;
            _results = results;
            _averageStressDescription = averageStressDescription;
            _averageScore = averageScore;  // averageScore
          });
        } else {
          Dialogs().onlyContentOneActionDialog(context: context, content: '기록 로드 중 오류\n${historyResList.last}', firstText: '확인');
        }
      }

      setState(() {
        _loading = false;
      });
    } catch(e) {
      print('error userInit of stress history : $e');
    }
  }

  String getEvaluationDescription(int score) {
    switch (score) {
      case 5:
        return "매우 높음";
      case 4:
        return "높음";
      case 3:
        return "중간";
      case 2:
        return "낮음";
      case 1:
        return "매우 낮음";
      default:
        return "평가되지 않음";
    }
  }

  String getCategoryName(int index) {
    if (index < 8) {
      return "스트레스 원인";
    } else if (index < 16) {
      return "스트레스 증상";
    } else {
      return "대처 방안";
    }
  }

  String getAverageStressDescription(double average) {
    if (average >= 4.5) {
      return "매우 높음";
    } else if (average >= 3.5) {
      return "높음";
    } else if (average >= 2.5) {
      return "중간";
    } else if (average >= 1.5) {
      return "낮음";
    } else {
      return "매우 낮음";
    }
  }

  Map<String, String> groupDetailsByCategory(List<int> scores) {
    Map<String, String> groupedDetails = {
      "스트레스 원인": "",
      "스트레스 증상": "",
      "대처 방안": "",
    };

    for (int i = 0; i < scores.length; i++) {
      String category = getCategoryName(i);
      String detail = getCategoryDetail(i);
      String evaluation = getEvaluationDescription(scores[i]);

      // 높음 이상일 경우에만 넣음
      if (evaluation.contains('높음')) {
        String beforeEvaluation = groupedDetails[category] ?? "";
        beforeEvaluation += "$detail, ";
        groupedDetails[category] = beforeEvaluation;
      }
    }

    // 마지막 쉼표와 공백 제거
    groupedDetails.forEach((key, value) {
      if (value.endsWith(', ')) {
        groupedDetails[key] = value.substring(0, value.length - 2);
      }
    });

    return groupedDetails;
  }

  String getCategoryDetail(int index) {
    const details = [
      "치열한 경쟁", "과제 부담", "교수님과의 관계", "평가", "학업 부담", "수업 난이도", "수업 참여 부담", "제한된 시간",
      "수면 장애", "만성 피로", "두통", "복부 통증 등의 소화 문제", "손톱 물기", "졸음", "불안감", "우울감", "절망감", "집중 저하", "공격성 증가", "논쟁 경향", "사람들로부터의 고립", "학업에 대한 무관심", "음식 섭취 증가 또는 감소",
      "능동적 대응", "계획 수립 및 수행", "자신에 대한 칭찬", "종교적 신념", "상황에 대한 정보 수집", "감정 표출 및 비밀 공유"
    ];

    return details[index];
  }

  String formatDateTime(DateTime dateTime) {
    String year = DateFormat('yyyy').format(dateTime);
    String month = DateFormat('MM').format(dateTime);
    String day = DateFormat('dd').format(dateTime);
    String hour = DateFormat('hh').format(dateTime);
    String minute = DateFormat('mm').format(dateTime);
    String period = DateFormat('a').format(dateTime) == 'AM' ? '오전' : '오후';

    return '$year년 $month월 $day일 $period $hour시 $minute분';
  }
}