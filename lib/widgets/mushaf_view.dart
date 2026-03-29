import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:my_perfect_quran/widgets/renderer/interactive_pageview_quran.dart';
import 'package:my_perfect_quran/widgets/analysis_dialogs.dart';

class MushafView extends StatelessWidget {
  final int initialPage;
  final Function(int) onPageChanged;
  final PageController? controller;
  final (int, int)? highlightedAyah;
  final void Function(int surah, int verse)? onAyahLongPress;

  const MushafView({
    super.key, 
    required this.initialPage, 
    required this.onPageChanged,
    this.controller,
    this.highlightedAyah,
    this.onAyahLongPress,
  });

  void _showWordDialog(BuildContext context, int surah, int verse, String word, String font, int wordIndex) {
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
      sp: 1.0,
      h: 1.0,
      theme: QcfThemeData(
        pageBackgroundColor: Colors.white,
        verseTextColor: Colors.black,
        verseNumberColor: const Color(0xFF1E5B30),
        verseBackgroundColor: (surah, verse) {
          if (highlightedAyah != null && 
              highlightedAyah!.$1 == surah && 
              highlightedAyah!.$2 == verse) {
            return Colors.yellow.withOpacity(0.3);
          }
          return Colors.transparent;
        },
      ),
      onWordTap: (surah, verse, word, font, wordIndex) => _showWordDialog(context, surah, verse, word, font, wordIndex),
      onAyahTap: (surah, verse) => _showAyahDialog(context, surah, verse),
      onAyahLongPress: onAyahLongPress,
    );
  }
}