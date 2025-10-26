import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  static void show({required String msg}) {
    Fluttertoast.cancel();
    Fluttertoast.showToast(msg: msg);
  }
}
