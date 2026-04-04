import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:my_perfect_quran/core/theme/typography.dart';

class MyCustomHeaderWidget extends StatelessWidget {
  final int surahNumber;
  const MyCustomHeaderWidget(this.surahNumber, {super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      // Change margin to a fixed or smaller value to prevent pushing boundaries
      margin: EdgeInsets.symmetric(vertical: 5.h), 
      padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 8.w),
      decoration: const BoxDecoration(
        border: Border.symmetric(
          horizontal: BorderSide(color: Color(0xFF1E5B30), width: 1.5),
        ),
      ),
      // Use FittedBox to ensure if the text is too big, it scales down instead of overflowing
      child: Center(
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            "سُورَة ${getSurahName(surahNumber)}",
            style: AppTypography.surahHeader(
              fontSize: 20.sp,
              color: const Color(0xFF1E5B30),
            ),
          ),
        ),
      ),
    );
  }
}