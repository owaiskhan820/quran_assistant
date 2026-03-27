import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/widgets/search_dialog.dart';

class MushafHeader extends StatelessWidget {
  final int pageNumber;
  final String surahName;
  final String juzInfo;
  final Function(int) onSearchPage;
  final VoidCallback onSurahTap;
  final VoidCallback onJuzTap;

  const MushafHeader({
    super.key,
    required this.pageNumber,
    required this.surahName,
    required this.juzInfo,
    required this.onSearchPage,
    required this.onSurahTap,
    required this.onJuzTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade200, width: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _HeaderButton(
            label: surahName,
            onTap: onSurahTap,
          ),
          _HeaderButton(
            label: pageNumber.toString(),
            onTap: () async {
              final result = await showDialog<int>(
                context: context,
                builder: (_) => const MushafSearchDialog(),
              );
              if (result != null) {
                onSearchPage(result);
              }
            },
          ),
          _HeaderButton(
            label: juzInfo,
            onTap: onJuzTap,
          ),
        ],
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _HeaderButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
        child: Text(
          label,
          style: TextStyle(
            color: const Color(0xFF1E5B30),
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            decoration: TextDecoration.underline,
            decorationStyle: TextDecorationStyle.dashed,
          ),
        ),
      ),
    );
  }
}