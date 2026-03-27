import 'package:flutter_test/flutter_test.dart';

void main() {
  test('audio url formatting test', () {
    String getUrl(int surah, int ayah, int wordIndex) {
      String s = surah.toString().padLeft(3, '0');
      String a = ayah.toString().padLeft(3, '0');
      String w = wordIndex.toString().padLeft(3, '0');

      if (ayah == 0) {
        s = "001";
        a = "001";
        if (wordIndex < 1 || wordIndex > 4) w = "001";
      }

      return "https://audio.qurancdn.com/wbw/${s}_${a}_${w}.mp3";
    }

    expect(getUrl(2, 4, 1), "https://audio.qurancdn.com/wbw/002_004_001.mp3");
    expect(getUrl(114, 1, 3), "https://audio.qurancdn.com/wbw/114_001_003.mp3");
    expect(getUrl(2, 0, 1), "https://audio.qurancdn.com/wbw/001_001_001.mp3"); // Bismillah fallback
    expect(getUrl(2, 0, 4), "https://audio.qurancdn.com/wbw/001_001_004.mp3"); // Bismillah fallback word 4
  });
}
