import 'package:devjang_cs/models/colors_model.dart';
import 'package:devjang_cs/models/debate_result.dart';
import 'package:devjang_cs/models/user_model.dart';
import 'package:devjang_cs/providers/page_provider.dart';
import 'package:devjang_cs/services/auth_service.dart';
import 'package:devjang_cs/services/chat_services.dart';
import 'package:devjang_cs/services/classification_platform.dart';
import 'package:devjang_cs/services/user_services.dart';
import 'package:devjang_cs/widgets/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:intl/intl.dart';

class DebateHistoryPage extends StatefulWidget {
  const DebateHistoryPage({Key? key}) : super(key: key);

  @override
  State<DebateHistoryPage> createState() => _DebateHistoryPageState();
}

class _DebateHistoryPageState extends State<DebateHistoryPage> {

  PageProvider _pageProvider = PageProvider();
  final ColorsModel _colorsModel = ColorsModel();
  UserModel _userModel = UserModel();
  Map _historyMap = {};  // {Datetime time : {'comment': , 'result': List<EvaluationResult>}}
  DateTime? _selectTime;
  String _comment = '';
  List<DebateResult> _results = [];
  bool _loading = false;

  // initState는 현재 코드 클래스 호출시 최초 1회 호출되는 함수이다
  // 현재 코드 페이지를 호출할 때 가장 먼저 작업할 함수들을 넣어주면 된다
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      // provider를 사용시 초기에는 정보를 바로 못받아오는 경우가 있어서
      // 최초 1회 빌드 후 호출하게 해둠
      userInit();
    });
  }

  @override
  Widget build(BuildContext context) {
    _pageProvider = Provider.of<PageProvider>(context, listen: true);

    var screenWidth = MediaQuery.of(context).size.width;
    // 가로 사이즈에 따라서 플랫폼 구별
    bool isWeb = ClassificationPlatform().classifyWithScreenSize(context: context) == 2;

    print('_results ${_results}');
    return Stack(
      children: [
        ListView(
          children: [
            const SizedBox(height: 15,),
            _pageProvider.isFromChat ? Container() : selectDateWidget(screenWidth, isWeb),
            _pageProvider.isFromChat ? Container() : const SizedBox(height: 15,),
            _comment.isEmpty ? Container() : Padding(
              padding: const EdgeInsets.only(left: 60, right: 60),
              child: Text("${_comment}", style: const TextStyle(
                fontSize: 20,
                color: Colors.black,
              ), textAlign: TextAlign.center, ),
            ),
            _comment.isEmpty ? Container() : const SizedBox(height: 15,),
            _results.isEmpty ? _comment.isNotEmpty ? Container() : Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 60.0),
                child: Text("아직 대화 기록이 없습니다", style: TextStyle(
                  fontSize: 16,
                  color: _colorsModel.gr1,
                ),),
              ),
            ) :ListView.builder(
              physics: NeverScrollableScrollPhysics(),
                shrinkWrap: true,
                itemCount: _results.length,
                itemBuilder: (BuildContext context, int index) {
                  return evaluateWidget(screenWidth, isWeb, _results[index]);
                }),
          ],
        ),
        _loading ? Center(child: CircularProgressIndicator(color: _colorsModel.main,),) : Container()
      ],
    );
  }

  Widget evaluateWidget(screenWidth, isWeb, DebateResult evaluationResult) {

    Color evaluationColor = _colorsModel.blue;

    if (evaluationResult.evaluation.toString().contains('상')) {
      evaluationColor = _colorsModel.blue;
    } else if (evaluationResult.evaluation.toString().contains('중')) {
      evaluationColor = _colorsModel.orange;
    } else if (evaluationResult.evaluation.toString().contains('하')) {
      evaluationColor = _colorsModel.red;
    }

    return Padding(
      padding: isWeb ? const EdgeInsets.only(left: 60, right: 60, bottom: 30) : const EdgeInsets.only(left: 15, right: 15, bottom: 10),
      child: Container(
        width: screenWidth,
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
          padding: isWeb ? const EdgeInsets.only(left: 60, right: 60, top: 30, bottom: 30) : const EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: screenWidth * 0.4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text("• ${evaluationResult.category}", style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),),
                    const SizedBox(height: 15,),
                    Text("${evaluationResult.evaluation}", style: TextStyle(
                      fontSize: 16,
                      color: evaluationColor,
                      fontWeight: FontWeight.bold,
                    ),),
                  ],
                ),
              ),
              SizedBox(
                width: screenWidth * 0.4,
                child: Text("${evaluationResult.details}", style: const TextStyle(
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
      return Padding(
        padding: isWeb ? const EdgeInsets.only(left: 60, right: 60) : const EdgeInsets.only(left: 15, right: 15),
        child: Column(
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
                    String comment = '';
                    List<DebateResult> results = [];

                    if (_historyMap.isNotEmpty) {
                      Map dataMap = _historyMap[value] ?? {};
                      comment = dataMap['comment'] ?? '';
                      results = dataMap['result'];
                    }

                    setState(() {
                      _selectTime = value;
                      _comment = comment;
                      _results = results;
                    });
                  },
                  buttonHeight: 40,
                  buttonWidth: 90,
                  itemHeight: 40,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  // 서버에서 유저정보를 가져옴
  Future<void> userInit() async {
    setState(() {
      _loading = true;
    });

    List resList = await UserServices().getUserModel(uid: AuthService().getUid());

    if (resList.first) {
      setState(() {
        _userModel = resList.last;
      });

      if (_pageProvider.isFromChat) {
        List chatEvaluations = _pageProvider.chatEvaluations;
        if (chatEvaluations.isNotEmpty) {
          setState(() {
            _comment = chatEvaluations.first;
            _results = chatEvaluations.last;
          });
        }
      } else {
        List historyResList = await ChatServices().getDebateHistory(uid: _userModel.uid, chatModelKey: _pageProvider.selectChatModel.key);
        if (historyResList.first) {
          Map historyMap = historyResList.last; // {Datetime time : {'comment': , 'result': List<EvaluationResult>}}

          // 키인 Datetime을 리스트로 변환하여 정렬
          List timeList = historyMap.keys.toList();
          timeList.sort((a, b) => b.compareTo(a)); // 최신순으로 정렬

          // 정렬된 시간 리스트를 이용하여 새로운 Map 생성
          Map<DateTime, Map<String, dynamic>> tempHistoryMap = {};
          for (DateTime time in timeList) {
            tempHistoryMap[time] = historyMap[time];
          }

          // 기존 historyMap을 정렬된 tempHistoryMap으로 대체
          historyMap = tempHistoryMap;

          DateTime? selectTime;
          String comment = '';
          List<DebateResult> results = [];

          if (historyMap.isNotEmpty) {
            selectTime = historyMap.keys.toList().first;

            Map dataMap = historyMap[selectTime] ?? {};
            comment = dataMap['comment'] ?? '';
            results = dataMap['result'];
          }

          setState(() {
            _historyMap = historyMap;
            _selectTime = selectTime;
            _comment = comment;
            _results = results;
          });
        } else {
          Dialogs().onlyContentOneActionDialog(context: context, content: '기록 로드 중 오류\n${historyResList.last}', firstText: '확인');
        }
      }
    }

    setState(() {
      _loading = false;
    });
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
