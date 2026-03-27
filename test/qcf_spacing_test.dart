import 'package:flutter_test/flutter_test.dart';
import 'package:qcf_quran/qcf_quran.dart';

void main() {
  test('qcf check spacing', () {
    final text = getVerseQCF(2, 4, verseEndSymbol: false);
    print('Raw chars:');
    for (int i = 0; i < text.length; i++) {
        print('${text.codeUnitAt(i)}');
    }
  });
}
