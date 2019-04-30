import 'package:shared_preferences/shared_preferences.dart';

class SPUtils {
  static Future<SharedPreferences> spInstance() async {
    return await SharedPreferences.getInstance();
  }
}
