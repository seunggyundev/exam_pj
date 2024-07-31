import 'package:devjang_cs/models/colors_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ToastWidget {
  ColorsModel _colorsModel = ColorsModel();

  showToast(String msg) {
    Fluttertoast.showToast(
        msg: msg,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        backgroundColor: _colorsModel.wh,
        textColor: _colorsModel.bl,
        fontSize: 16.0
    );
  }
}