import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

void main() {
  print("--- Page 1 Data ---");
  final p1 = getPageData(1);
  print("Ranges: $p1");
  for (var r in p1) {
    int start = r['start'];
    int end = r['end'];
    for (int v = start; v <= end; v++) {
      print("Page 1, Verse $v: Symbol='${getVerseNumberQCF(r['surah'], v)}'");
    }
  }

  print("\n--- Page 2 Data ---");
  final p2 = getPageData(2);
  print("Ranges: $p2");
  for (var r in p2) {
    int start = r['start'];
    int end = r['end'];
    for (int v = start; v <= end; v++) {
      print("Page 2, Verse $v: Symbol='${getVerseNumberQCF(r['surah'], v)}'");
    }
  }
}
