import 'package:flutter_test/flutter_test.dart';
import 'package:qcf_quran/qcf_quran.dart';

void main() {
  test('qcf text split by character check', () {
    final text = getVerseQCF(2, 4, verseEndSymbol: false);
    
    // remove newlines and spaces, then split by character
    final charList = text.replaceAll(RegExp(r'\s+'), '').split('');
    
    print('Char count: ${charList.length}');
    for (var i = 0; i < charList.length; i++) {
        print('Char $i: ${charList[i]}');
    }
  });
}
