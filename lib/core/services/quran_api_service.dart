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

  static String getSurahName(int surahNumber) {
    const names = {
      1: "Al-Fatihah", 2: "Al-Baqarah", 3: "Ali 'Imran", 4: "An-Nisa'", 5: "Al-Ma'idah",
      6: "Al-An'am", 7: "Al-A'raf", 8: "Al-Anfal", 9: "At-Tawbah", 10: "Yunus",
      11: "Hud", 12: "Yusuf", 13: "Ar-Ra'd", 14: "Ibrahim", 15: "Al-Hijr",
      16: "An-Nahl", 17: "Al-Isra'", 18: "Al-Kahf", 19: "Maryam", 20: "Ta-Ha",
      21: "Al-Anbiya'", 22: "Al-Hajj", 23: "Al-Mu'minun", 24: "An-Nur", 25: "Al-Furqan",
      26: "Ash-Shu'ara'", 27: "An-Naml", 28: "Al-Qasas", 29: "Al-Ankabut", 30: "Ar-Rum",
      31: "Luqman", 32: "As-Sajdah", 33: "Al-Ahzab", 34: "Saba'", 35: "Fatir",
      36: "Ya-Sin", 37: "As-Saffat", 38: "Sad", 39: "Az-Zumar", 40: "Ghafir",
      41: "Fussilat", 42: "Ash-Shura", 43: "Az-Zukhruf", 44: "Ad-Dukhan", 45: "Al-Jathiyah",
      46: "Al-Ahqaf", 47: "Muhammad", 48: "Al-Fath", 49: "Al-Hujurat", 50: "Qaf",
      51: "Adh-Dhariyat", 52: "At-Tur", 53: "An-Najm", 54: "Al-Qamar", 55: "Ar-Rahman",
      56: "Al-Waqi'ah", 57: "Al-Hadid", 58: "Al-Mujadila", 59: "Al-Hashr", 60: "Al-Mumtahanah",
      61: "As-Saff", 62: "Al-Jumu'ah", 63: "Al-Munafiqun", 64: "At-Taghabun", 65: "At-Talaq",
      66: "At-Tahrim", 67: "Al-Mulk", 68: "Al-Qalam", 69: "Al-Haqqah", 70: "Al-Ma'arij",
      71: "Nuh", 72: "Al-Jinn", 73: "Al-Muzzammil", 74: "Al-Muddaththir", 75: "Al-Qiyamah",
      76: "Al-Insan", 77: "Al-Mursalat", 78: "An-Naba'", 79: "An-Nazi'at", 80: "Abasa",
      81: "At-Takwir", 82: "Al-Infitar", 83: "Al-Mutaffifin", 84: "Al-Inshiqaq", 85: "Al-Buruj",
      86: "At-Tariq", 87: "Al-A'la", 88: "Al-Ghashiyah", 89: "Al-Fajr", 90: "Al-Balad",
      91: "Ash-Shams", 92: "Al-Layl", 93: "Ad-Duha", 94: "Ash-Sharh", 95: "At-Tin",
      96: "Al-Alaq", 97: "Al-Qadr", 98: "Al-Bayyinah", 99: "Az-Zalzalah", 100: "Al-Adiyat",
      101: "Al-Qari'ah", 102: "At-Takathur", 103: "Al-Asr", 104: "Al-Humazah", 105: "Al-Fil",
      106: "Quraysh", 107: "Al-Ma'un", 108: "Al-Kawthar", 109: "Al-Kafirun", 110: "An-Nasr",
      111: "Al-Masad", 112: "Al-Ikhlas", 113: "Al-Falaq", 114: "An-Nas"
    };
    return names[surahNumber] ?? "Surah $surahNumber";
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