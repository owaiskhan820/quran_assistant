import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/core/services/audio_service.dart';
import 'package:my_perfect_quran/widgets/translation_view.dart';

class WordAnalysisDialog extends StatefulWidget {
  final String word;
  final String fontFamily;
  final int surahNumber;
  final int verseNumber;
  final int wordIndex;

  const WordAnalysisDialog({
    super.key,
    required this.word,
    required this.fontFamily,
    required this.surahNumber,
    required this.verseNumber,
    required this.wordIndex,
  });

  @override
  State<WordAnalysisDialog> createState() => _WordAnalysisDialogState();
}

class _WordAnalysisDialogState extends State<WordAnalysisDialog> {
  String _selectedOption = "Urdu Script";
  final List<String> _options = ["Meaning", "Explanation", "Urdu Script"];
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        height: 0.35.sh,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFF8F4ED),
          borderRadius: BorderRadius.circular(28.r),
        ),
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            // Top Dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: const Color(0xFF1E5B30).withValues(alpha: 0.1)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: _selectedOption,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1E5B30)),
                  items: _options.map((String option) {
                    return DropdownMenuItem<String>(
                      value: option,
                      child: Text(
                        option,
                        style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1E5B30)),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() => _selectedOption = newValue);
                    }
                  },
                ),
              ),
            ),
            const Spacer(),
            // Center Word
            Text(
              widget.word,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: widget.fontFamily,
                package: 'qcf_quran',
                fontSize: 48.sp,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            // Bottom Play Button
            ElevatedButton.icon(
              onPressed: _isLoading
                  ? null
                  : () async {
                      setState(() => _isLoading = true);
                      try {
                        await AudioService.instance.playWordAudio(
                          widget.surahNumber,
                          widget.verseNumber,
                          widget.wordIndex,
                        );
                      } finally {
                        if (mounted) setState(() => _isLoading = false);
                      }
                    },
              icon: _isLoading
                  ? SizedBox(
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow, color: Colors.white, size: 20),
              label: Text(
                _isLoading ? "Loading..." : "Listen",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E5B30),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class AyahAnalysisDialog extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;

  const AyahAnalysisDialog({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
  });

  @override
  State<AyahAnalysisDialog> createState() => _AyahAnalysisDialogState();
}

class _AyahAnalysisDialogState extends State<AyahAnalysisDialog> {
  String _selectedOption = "Translation";
  final List<String> _options = ["Tafseer", "Translation"];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 40.h),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF8F4ED),
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(20.w, 20.h, 20.w, 0),
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: const Color(0xFF1E5B30).withValues(alpha: 0.1)),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedOption,
                    isExpanded: true,
                    icon: const Icon(Icons.keyboard_arrow_down, color: Color(0xFF1E5B30)),
                    items: _options.map((String option) {
                      return DropdownMenuItem<String>(
                        value: option,
                        child: Text(
                          option,
                          style: TextStyle(fontSize: 14.sp, color: const Color(0xFF1E5B30)),
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() => _selectedOption = newValue);
                      }
                    },
                  ),
                ),
              ),
            ),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: EdgeInsets.fromLTRB(20.w, 24.h, 20.w, 20.h),
                children: [
                  TranslationView(
                    surahNumber: widget.surahNumber,
                    verseNumber: widget.verseNumber,
                  ),
                  SizedBox(height: 32.h),
                  Text(
                    "Surah ${widget.surahNumber}, Ayah ${widget.verseNumber}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF1E5B30).withValues(alpha: 0.6),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        AudioService.instance.playAyah(widget.surahNumber, widget.verseNumber);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.play_arrow, color: Colors.white, size: 24),
                      label: Text(
                        "Play Ayah",
                        style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E5B30),
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 48.w, vertical: 14.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
