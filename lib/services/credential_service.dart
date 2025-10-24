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

  static String? get cached => _cache;
  static Future<String?> load() async {
    if (_cache != null) return _cache;
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_kAPiKey);
    _cache = value;
    return value;
  }
}
