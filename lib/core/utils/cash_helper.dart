import 'package:shared_preferences/shared_preferences.dart';

class CashHelper {
  static SharedPreferences? _prefs;
  static late SharedPreferences sharedPreference;

  static Future<SharedPreferences> init() async {
    _prefs ??= await SharedPreferences.getInstance();
    sharedPreference = _prefs!;
    return sharedPreference;
  }

  // تم تعديل هذه الدالة لتكون آمنة وتدعم كافة الأنواع بدون أخطاء
  static Future<bool> setData(String key, dynamic value) async {
    if (value == null) return false;

    if (value is bool) {
      return await sharedPreference.setBool(key, value);
    } else if (value is String) {
      return await sharedPreference.setString(key, value);
    } else if (value is int) {
      return await sharedPreference.setInt(key, value);
    } else if (value is double) {
      return await sharedPreference.setDouble(key, value);
    } else if (value is List<String>) {
      // ✅ أضفنا هذا الجزء لدعم حفظ قائمة الـ IDs
      return await sharedPreference.setStringList(key, value);
    }

    return false;
  }

  static dynamic getData(String key) {
    try {
      return sharedPreference.get(key);
    } catch (_) {
      // If late variable is not initialized yet
      return null;
    }
  }

  static Future<bool> removeData(String key) async {
    return await sharedPreference.remove(key);
  }
}
