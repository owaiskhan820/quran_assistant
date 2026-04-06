import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:quran_assistant/widgets/renderer/interactive_pageview_quran.dart';
import 'package:quran_assistant/widgets/analysis_dialogs.dart';
import 'package:quran_assistant/core/navigation/nav_controller.dart';
import 'package:quran_assistant/core/services/audio_service.dart';

class MushafView extends StatelessWidget {
  final int initialPage;
  final Function(int) onPageChanged;
  final PageController? controller;
  final (int, int)? highlightedAyah;
  final void Function(int surah, int verse)? onAyahLongPress;

  final double fontScale; 
  final double heightScale;

  const MushafView({
    super.key, 
    required this.initialPage, 
    required this.onPageChanged,
    this.controller,
    this.highlightedAyah,
    this.onAyahLongPress,
    this.fontScale = 0.85, 
    this.heightScale = 0.94,
  });

  void _showWordDialog(BuildContext context, int surah, int verse, String word, String font, int wordIndex) {
    AudioService.instance.stop();
    showBottomNavNotifier.value = true;
    showDialog(
      context: context,
      builder: (context) => WordAnalysisDialog(
        word: word,
        fontFamily: font,
        surahNumber: surah,
        verseNumber: verse,
        wordIndex: wordIndex,
      ),
    );
  }

  void _showAyahDialog(BuildContext context, int surah, int verse) {
    AudioService.instance.stop();
    showBottomNavNotifier.value = true;
    showDialog(
      context: context,
      builder: (context) => AyahAnalysisDialog(
        surahNumber: surah,
        verseNumber: verse,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return InteractivePageviewQuran(
      initialPageNumber: initialPage,
      controller: controller,
      onPageChanged: onPageChanged,
      fontScale: fontScale, // This fixes the width scaling
      heightScale: heightScale,   // This fixes the 15-line height
      highlightedAyah: highlightedAyah,
      theme: const QcfThemeData(
        pageBackgroundColor: Colors.white,
        verseTextColor: Colors.black,
        verseNumberColor: Color(0xFF1E5B30),
      ),
      onWordTap: (surah, verse, word, font, wordIndex) => _showWordDialog(context, surah, verse, word, font, wordIndex),
      onAyahTap: (surah, verse) => _showAyahDialog(context, surah, verse),
      onAyahLongPress: onAyahLongPress,
    );
  }
}