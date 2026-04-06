import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_assistant/services/translation_service.dart';
import 'package:quran_assistant/core/theme/typography.dart';

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
            style: AppTypography.urduTranslation(
              fontSize: 17.sp,
              color: Colors.black87,
            ),
          );
        } else {
          final englishTranslation = TranslationService.instance.getEnglishTranslation(surahNumber, verseNumber);
          return Text(
            englishTranslation,
            textAlign: TextAlign.left,
            style: AppTypography.englishTranslation(
              fontSize: 17.sp,
              color: Colors.black87,
            ),
          );
        }
      },
    );
  }
}
