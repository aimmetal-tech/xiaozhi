import 'package:shared_preferences/shared_preferences.dart';

class ApiKeyStore {
  static const _kAPiKey = 'api_key';
  static String? _cache;

  static Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _cache = prefs.getString(_kAPiKey);
  }

  static Future<void> save(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kAPiKey, value);
    _cache = value;
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kAPiKey);
    _cache = null;
  }

  static String? get sync => _cache;
  static Future<String?> get async async =>
      _cache ?? (await SharedPreferences.getInstance()).getString(_kAPiKey);
}
