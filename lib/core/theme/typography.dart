import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  // Global Font Families
  static const String englishFont = 'Inter';
  static const String urduFont = 'Noto Nastaliq Urdu';
  static const String fallbackUrduFont = 'Jameel Noori Nastaliq Kasheeda';

  // Base Text Styles
  static TextStyle get englishBase => GoogleFonts.inter();
  
  static TextStyle get urduBase => const TextStyle(
        fontFamily: urduFont,
        height: 2.0,
      );

  // Specialized Styles
  static TextStyle urduTranslation({double? fontSize, Color? color}) => urduBase.copyWith(
        fontSize: fontSize ?? 18,
        color: color ?? Colors.black87,
        fontWeight: FontWeight.w400,
      );

  static TextStyle englishTranslation({double? fontSize, Color? color}) => englishBase.copyWith(
        fontSize: fontSize ?? 16,
        color: color ?? Colors.black87,
        height: 1.5,
      );

  static TextStyle surahHeader({double? fontSize, Color? color}) => const TextStyle(
        fontFamily: 'Amiri', // Keeping Amiri for specific Arabic headers if needed, or we can use Urdu font
        fontSize: 22,
        color: Color(0xFF1E5B30),
      );
}
