import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static SharedPreferences? _preferences;

  Future<SharedPreferences> get preferences async {
    if (_preferences != null) return _preferences!;
    _preferences = await SharedPreferences.getInstance();
    return _preferences!;
  }

  Future<void> setToken(String token) async {
    final prefs = await preferences;
    await prefs.setString('token', token);
  }

  Future<String?> getToken() async {
    final prefs = await preferences;
    return prefs.getString('token');
  }

  Future<void> removeToken() async {
    final prefs = await preferences;
    await prefs.remove('token');
  }

  Future<void> setUserId(String userId) async {
    final prefs = await preferences;
    await prefs.setString('userId', userId);
  }

  Future<String?> getUserId() async {
    final prefs = await preferences;
    return prefs.getString('userId');
  }

  Future<void> clear() async {
    final prefs = await preferences;
    await prefs.clear();
  }
}