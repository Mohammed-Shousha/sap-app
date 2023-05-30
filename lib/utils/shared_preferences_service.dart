import 'package:shared_preferences/shared_preferences.dart';

Future<void> setUserId(String userId) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.setString('userId', userId);
}

Future<String> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('userId') ?? '';
  return userId;
}

Future<void> removeUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  prefs.remove('userId');
}
