import 'package:qcf_quran/qcf_quran.dart';
import 'package:quran_assistant/core/navigation.dart';

class QuranNavigationHelper {
  static int getPageNumber(int surah, int ayah) {
    // Ensuring actual Madani Mushaf page boundaries from the data provider
    for (int p = 1; p <= 604; p++) {
      final data = getPageData(p);
      for (final range in data) {
        if (range['surah'] == surah && 
            ayah >= range['start'] && 
            ayah <= range['end']) {
          return p;
        }
      }
    }
    return 1; // Fallback to page 1
  }

  static void jumpToAyah(int surah, int ayah) {
    final pageNum = getPageNumber(surah, ayah);
    if (quranPageKey.currentState != null) {
      (quranPageKey.currentState as dynamic).onSearchAndHighlight(pageNum, surah, ayah);
    }
  }
}

