import 'package:devjang_cs/models/colors_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

}