import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

class AIService {
  static final AIService _instance = AIService._internal();
  factory AIService() => _instance;
  AIService._internal();

  late final GenerativeModel _model;

  void init() {
    final apiKey = dotenv.env['GEMINI_API_KEY'];
    if (apiKey == null) {
      throw Exception('GEMINI_API_KEY not found in .env file');
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-flash',
      apiKey: apiKey,
    );
  }

  Future<Map<String, int>> recognizeAyah(Uint8List imageBytes) async {
    try {
      final prompt = '''
        You are a Quranic expert. Analyze this image. 
        Identify the Surah and Ayah number. 
        Return ONLY a JSON object: {"surah": 18, "ayah": 10}. 
        If you see multiple Ayahs, return the first one.
      ''';
      
      final content = [
        Content.multi([
          TextPart(prompt),
          DataPart('image/png', imageBytes),
        ]),
      ];

      final response = await _model.generateContent(content);
      final text = response.text;



      if (text == null || text.isEmpty) {
        throw Exception("Gemini returned an empty response.");
      }

      // Robust JSON extraction using Regex
      // This finds the first occurrence of something that looks like a JSON object {...}
      final jsonRegex = RegExp(r'\{[\s\S]*?\}');
      final match = jsonRegex.firstMatch(text);
      
      if (match == null) {
        throw Exception("Could not find JSON in AI response: $text");
      }

      String jsonString = match.group(0)!;
      
      try {
        final Map<String, dynamic> data = jsonDecode(jsonString);
        
        // Support both 'surah' and 'surah_number' for extra resilience
        final surahRaw = data['surah'] ?? data['surah_number'];
        final ayahRaw = data['ayah'] ?? data['ayah_number'];

        if (surahRaw == null || ayahRaw == null) {
          throw Exception("Missing surah/ayah keys in AI response: $jsonString");
        }
        
        final int surah = (surahRaw is int) ? surahRaw : int.parse(surahRaw.toString());
        final int ayah = (ayahRaw is int) ? ayahRaw : int.parse(ayahRaw.toString());
        
        return {
          'surah': surah,
          'ayah': ayah,
        };
      } on FormatException catch (e) {
        throw Exception("Invalid JSON format from AI: $e\nResponse: $jsonString");
      }
    } catch (e) {

      rethrow; // Rethrow to let the UI handle specific messages
    }
  }
}
