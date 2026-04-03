import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/services/translation_service.dart';

class TranslationView extends StatelessWidget {
  final int surahNumber;
  final int verseNumber;
  final ValueListenable<String> selectedLanguage;

  const TranslationView({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
    required this.selectedLanguage,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: selectedLanguage,
      builder: (context, lang, child) {
        if (lang == 'ur') {
          final urduTranslation = TranslationService.instance.getUrduTranslation(surahNumber, verseNumber);
          return Text(
            urduTranslation,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 17.sp,
              height: 2.0,
              color: Colors.black87,
              fontFamily: 'Noto Nastaliq Urdu',
              fontWeight: FontWeight.w400,
            ),
          );
        } else {
          final englishTranslation = TranslationService.instance.getEnglishTranslation(surahNumber, verseNumber);
          return Text(
            englishTranslation,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 17.sp,
              height: 1.5,
              color: Colors.black87,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
          );
        }
      },
    );
  }
}
