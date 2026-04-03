import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  static SettingsService get instance => _instance;

  SettingsService._internal();

  late SharedPreferences _prefs;

  static const String _kQariId = 'default_qari_id';
  static const String _kLang = 'default_translation_lang';

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  int get qariId => _prefs.getInt(_kQariId) ?? 7;
  
  Future<void> setQariId(int id) async {
    await _prefs.setInt(_kQariId, id);
  }

  String get translationLang => _prefs.getString(_kLang) ?? 'ur';

  Future<void> setTranslationLang(String lang) async {
    await _prefs.setString(_kLang, lang);
  }
}
