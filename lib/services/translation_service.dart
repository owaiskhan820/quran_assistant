import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/foundation.dart';

Map<String, String> _parseTranslationMap(String raw) {
  final Map<String, String> result = {};
  if (raw == "{}" || raw.isEmpty) return result;
  try {
    final parsed = json.decode(raw) as Map<String, dynamic>;
    if (parsed.containsKey('quran')) {
      for (var item in parsed['quran'] as List) {
        result['${item['chapter']}:${item['verse']}'] = item['text'].toString();
      }
    } else {
      result.addAll(Map<String, String>.from(parsed));
    }
  } catch (e) {
    debugPrint("Parse error: $e");
  }
  return result;
}

class TranslationService {
  TranslationService._();
  static final TranslationService instance = TranslationService._();

  final ValueNotifier<String> currentLanguage = ValueNotifier<String>('ur');

  Map<String, String> _urduMap = {};
  Map<String, String> _englishMap = {};
  bool _loaded = false;

  Future<String> _safeLoadAsset(String path) async {
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      debugPrint('Missing asset: $path');
      return "{}";
    }
  }

  Future<void> loadLocalTranslations() async {
    if (_loaded) return;
    try {
      final urRaw = await _safeLoadAsset('assets/translations/ur_jalandhari.json');
      final enRaw = await _safeLoadAsset('assets/translations/en_sahih.json');

      _urduMap = await compute(_parseTranslationMap, urRaw);
      _englishMap = await compute(_parseTranslationMap, enRaw);
      
      _loaded = true;
    } catch (e) {
      debugPrint('Error loading translations: $e');
    }
  }

  String getUrduTranslation(int surah, int ayah) => _urduMap['$surah:$ayah'] ?? "Local cache missing";
  String getEnglishTranslation(int surah, int ayah) => _englishMap['$surah:$ayah'] ?? "Local cache missing";

  void toggleLanguage() {
    currentLanguage.value = currentLanguage.value == 'ur' ? 'en' : 'ur';
  }

  bool get isLoaded => _loaded;
}
