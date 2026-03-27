import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

class QuranApiService {
  static const String baseUrl = "https://api.quran.com/api/v4";
  
  // 1. Persistent client to avoid SSL handshake overhead on every tap
  static final http.Client _client = http.Client();

  // 2. Simple In-Memory Cache for translations
  static final Map<String, String> _translationCache = {};

  /// Fetches Urdu translation for a specific ayah.
  /// Using ID 158 (Fateh Muhammad Jalandhari)
  static Future<String?> getUrduTranslation(int surah, int ayah) async {
    final verseKey = "$surah:$ayah";
    
    // Check cache first - instant return if already fetched
    if (_translationCache.containsKey(verseKey)) {
      debugPrint("Serving translation from cache: $verseKey");
      return _translationCache[verseKey];
    }

    try {
      final url = Uri.parse("$baseUrl/quran/translations/158?verse_key=$verseKey");
      
      debugPrint("Fetching Urdu translation: $url");
      final response = await _client.get(url); // Using persistent client
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final translations = data['translations'] as List;
        if (translations.isNotEmpty) {
          final text = translations[0]['text'];
          _translationCache[verseKey] = text; // Save to cache
          return text;
        }
      }
    } catch (e) {
      debugPrint("Error fetching Urdu translation: $e");
    }
    return null;
  }

  static Future<String?> getAyahAudioUrl(int surah, int ayah, {int recitationId = 7}) async {
  try {
    // Pad IDs to 3 digits (e.g., Surah 1 -> 001, Ayah 7 -> 007)
    String s = surah.toString().padLeft(3, '0');
    String a = ayah.toString().padLeft(3, '0');

    // This is the NEW ultra-reliable CDN link
    // Pattern: https://audio.qurancdn.com/reciter/[ID]/mp3/[SSS AAA].mp3
    final directUrl = "https://audio.qurancdn.com/Alafasy/mp3/$s$a.mp3";
    
    debugPrint("Directly generated CDN URL: $directUrl");
    return directUrl;
  } catch (e) {
    debugPrint("Error generating ayah audio URL: $e");
  }
  return null;
}

  /// Close the client when the app is disposed (optional, but good practice)
  static void dispose() {
    _client.close();
  }
}