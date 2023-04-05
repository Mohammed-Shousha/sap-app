import 'package:shared_preferences/shared_preferences.dart';

Future<String> getUserId() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  String userId = prefs.getString('userId') ?? '';
  return userId;
}

Future<bool> getIsLoggedIn() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  return isLoggedIn;
}

class SharedPreferencesService {
  static late SharedPreferences _prefs;

  static Future<SharedPreferences> init() async =>
      _prefs = await SharedPreferences.getInstance();

  //sets
  static setBool(String key, bool value) => _prefs.setBool(key, value);

  static setDouble(String key, double value) => _prefs.setDouble(key, value);

  static setInt(String key, int value) => _prefs.setInt(key, value);

  static setString(String key, String value) => _prefs.setString(key, value);

  static setStringList(String key, List<String> value) =>
      _prefs.setStringList(key, value);

  //gets
  static bool? getBool(String key) => _prefs.getBool(key);

  static double? getDouble(String key) => _prefs.getDouble(key);

  static int? getInt(String key) => _prefs.getInt(key);

  static String? getString(String key) => _prefs.getString(key);

  static List<String>? getStringList(String key) => _prefs.getStringList(key);

  //deletes..
  static Future<bool> remove(String key) async => await _prefs.remove(key);

  static Future<bool> clear() async => await _prefs.clear();
}
