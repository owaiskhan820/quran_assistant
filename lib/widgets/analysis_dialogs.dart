import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/core/services/audio_service.dart';
import 'package:my_perfect_quran/core/services/quran_api_service.dart';

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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: const Color(0xFFFBF1E6),
      child: Container(
        width: 300.w,
        height: 300.w, // Ensure it's square
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // Top Dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFF1E5B30).withOpacity(0.3)),
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
                      debugPrint("Option tapped: $newValue");
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
                fontSize: 42.sp, // Reduced font size
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
                _isLoading ? "Loading..." : "Play Audio",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E5B30),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                elevation: 2,
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
  String? _translation;
  bool _isLoadingTranslation = true;

  @override
  void initState() {
    super.initState();
    _loadTranslation();
  }

  Future<void> _loadTranslation() async {
    setState(() {
      _isLoadingTranslation = true;
    });
    final translation = await QuranApiService.getUrduTranslation(
        widget.surahNumber, widget.verseNumber);
    if (mounted) {
      setState(() {
        _translation = translation;
        _isLoadingTranslation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      backgroundColor: const Color(0xFFFBF1E6),
      child: Padding(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Top Dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.5),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(color: const Color(0xFF1E5B30).withOpacity(0.3)),
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
                      debugPrint("Option selected: $newValue");
                    }
                  },
                ),
              ),
            ),
            SizedBox(height: 20.h),
            // Translation Area
            Container(
              constraints: BoxConstraints(maxHeight: 200.h),
              width: double.infinity,
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: SingleChildScrollView(
                child: _isLoadingTranslation
                    ? const Center(child: CircularProgressIndicator())
                    : Text(
                        _translation ?? "Translation not found.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: Colors.black87,
                        ),
                      ),
              ),
            ),
            SizedBox(height: 20.h),
            // Center Info (Surah:Ayah)
            Text(
              "Surah ${widget.surahNumber}, Ayah ${widget.verseNumber}",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E5B30),
              ),
            ),
            // Bottom Play Button
            ElevatedButton.icon(
              onPressed: () {
                AudioService.instance.playAyah(widget.surahNumber, widget.verseNumber);
                Navigator.pop(context);
              },
              icon: const Icon(Icons.play_arrow, color: Colors.white),
              label: Text(
                "Play Ayah",
                style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E5B30),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 8.h),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30.r)),
                elevation: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
