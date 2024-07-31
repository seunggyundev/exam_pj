import 'package:devjang_cs/models/colors_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:percent_indicator/percent_indicator.dart';

class Dialogs {
  ColorsModel _colorsModel = ColorsModel();

  Future<bool> yesOrNoDialog({required context,required title, required content}) async {
    var res = await showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('${title}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.black),),
            content: Text('${content}', style: TextStyle(fontSize: 14,),),
            actions: [
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context, false);
                },
                child: Text('취소', style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: _colorsModel.cupertinoAlertBtnText,
                ),),
              ),
              CupertinoDialogAction(
                onPressed: () {
                  Navigator.pop(context, true);
                },
                child: Text('확인', style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: _colorsModel.cupertinoAlertBtnText,
                ),),
              ),
            ],
          );
        });

    return res ?? false;
  }

  oneActionDialog({required context,required title, required content,required firstText,required firstPressed,}) {
    showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            title: Text('${title}', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w500, color: Colors.black),),
            content: Text('${content}', style: TextStyle(fontSize: 13,),),
            actions: [
              CupertinoDialogAction(
                onPressed: firstPressed,
                child: Text('${firstText}', style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: _colorsModel.bl,
                ),),
              ),
            ],
          );
        });
  }

  onlyContentOneActionDialog({required context,required content,required firstText, isDoublePop = false,
    action
  }) {

    showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text('${content}', style: TextStyle(fontSize: 14,),),
            actions: [
              CupertinoDialogAction(
                onPressed: action ?? () {
                  if (isDoublePop) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                child: Text('${firstText}', style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: _colorsModel.bl,
                ),),
              ),
            ],
          );
        });

  }

  onlyContentTwoActionsDialog({required context,required content,required firstText,required firstPressed,required secText,required secPressed,}) {
    showCupertinoDialog(
        barrierDismissible: true,
        context: context,
        builder: (BuildContext context) {
          return CupertinoAlertDialog(
            content: Text('${content}', style: TextStyle(fontSize: 14,),),
            actions: [
              CupertinoDialogAction(
                onPressed: firstPressed,
                child: Text('${firstText}', style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: _colorsModel.bl,
                ),),
              ),
              CupertinoDialogAction(
                onPressed: secPressed,
                child: Text('${secText}', style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w500,
                  color: _colorsModel.bl,
                ),),
              ),
            ],
          );
        });
  }

  Future<bool> showDialogWithTimer(BuildContext context) async {
    bool isCancelled = false;

    var res = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // 5초 후에 페이지 이동을 위한 타이머 시작
        Timer(Duration(seconds: 5), () {
          if (!isCancelled) {
            Navigator.pop(context, true); // 다이얼로그 닫기
          }
        });
        return AlertDialog(
          backgroundColor: _colorsModel.wh,
          content: CircularPercentIndicator(
            radius: 130.0,
            lineWidth: 10.0,
            animation: true,
            percent: 1,
            animationDuration: 5000,
            backgroundColor: _colorsModel.wh,
            center: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "5초 후에 평가결과 페이지로 이동합니다",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: _colorsModel.gr1),
                ),
              ],
            ),
            circularStrokeCap: CircularStrokeCap.round,
            progressColor: _colorsModel.main,
          ),
          actions: <Widget>[
            TextButton(
              child: Text('취소'),
              onPressed: () {
                isCancelled = true;
                Navigator.pop(context, false); // 다이얼로그 닫기
              },
            ),
          ],
        );
      },
    );

    return res ?? false;
  }
}