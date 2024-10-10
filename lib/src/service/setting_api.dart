import 'package:shared_preferences/shared_preferences.dart';

class SettingApi {
  static final SettingApi _instance = SettingApi._();

  factory SettingApi() => _instance;

  SettingApi._();

  static Future<void> init() async {
    _instance._prefsWithCache = await SharedPreferencesWithCache.create(
      cacheOptions: const SharedPreferencesWithCacheOptions(),
    );
    return;
  }

  late final SharedPreferencesWithCache _prefsWithCache;

  static Future<void> setBool(
    String key,
    bool value,
  ) async =>
      await _instance._prefsWithCache.setBool(key, value);
  static Future<void> setDouble(
    String key,
    double value,
  ) async =>
      await _instance._prefsWithCache.setDouble(key, value);
  static Future<void> setInt(
    String key,
    int value,
  ) async =>
      await _instance._prefsWithCache.setInt(key, value);
  static Future<void> setString(
    String key,
    String value,
  ) async =>
      await _instance._prefsWithCache.setString(key, value);
  static Future<void> setStringList(
    String key,
    List<String> value,
  ) async =>
      await _instance._prefsWithCache.setStringList(key, value);

  static bool? getBool(String key) => _instance._prefsWithCache.getBool(key);
  static double? getDouble(String key) =>
      _instance._prefsWithCache.getDouble(key);
  static int? getInt(String key) => _instance._prefsWithCache.getInt(key);
  static String? getString(String key) =>
      _instance._prefsWithCache.getString(key);
  static List<String>? getStringList(String key) =>
      _instance._prefsWithCache.getStringList(key);

  static bool containsKey(String key) =>
      _instance._prefsWithCache.containsKey(key);
  static Future<void> remove(String key) async =>
      await _instance._prefsWithCache.remove(key);

  static Future<void> addUp({
    required int uid,
    String? tag,
    String? pattern,
  }) async {
    await setStringList(
      'uids',
      (getStringList('uids') ?? [])..add(uid.toString()),
    );
    if (tag != null) {
      await setString('up_tag_$uid', tag);
    }
    if (pattern != null) {
      await setString('up_pattern_$uid', pattern);
    }
  }

  static Future<void> removeUp(int uid) async {
    await setStringList(
      'uids',
      (getStringList('uids') ?? [])..remove(uid.toString()),
    );
    if (containsKey('up_tag_$uid')) {
      await remove('up_tag_$uid');
    }
    if (containsKey('up_pattern_$uid')) {
      await remove('up_pattern_$uid');
    }
  }

  static List<
      ({
        int uid,
        String? tag,
        String? pattern,
      })> get Ups => [
        for (var uid in getStringList('uids') ?? <String>[])
          (
            uid: int.parse(uid),
            tag: getString('up_tag_$uid'),
            pattern: getString('up_pattern_$uid'),
          ),
      ];
}
