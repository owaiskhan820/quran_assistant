import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/core/services/quran_api_service.dart';

class TranslationView extends StatefulWidget {
  final int surahNumber;
  final int verseNumber;

  const TranslationView({
    super.key,
    required this.surahNumber,
    required this.verseNumber,
  });

  @override
  State<TranslationView> createState() => _TranslationViewState();
}

class _TranslationViewState extends State<TranslationView> {
  String? _urduTranslation;
  String? _englishTranslation;
  bool _isLoadingEn = true;
  bool _isLoadingUr = true;

  @override
  void initState() {
    super.initState();
    _loadTranslations();
  }

  Future<void> _loadTranslations() async {
    if (!mounted) return;
    
    // Load Urdu
    QuranApiService.getUrduTranslation(widget.surahNumber, widget.verseNumber).then((val) {
      if (mounted) setState(() {
        _urduTranslation = val;
        _isLoadingUr = false;
      });
    });

    // Load English
    QuranApiService.getEnglishTranslation(widget.surahNumber, widget.verseNumber).then((val) {
      if (mounted) setState(() {
        _englishTranslation = val;
        _isLoadingEn = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingEn && _isLoadingUr) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF1E5B30)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Urdu Translation (RTL)
        if (_urduTranslation != null) ...[
          Text(
            _urduTranslation!,
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 22.sp,
              height: 1.6,
              color: Colors.black,
              fontFamily: 'JameelNoori', // Assuming this font exists or use default
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 16.h),
        ],
        
        // Divider
        if (_urduTranslation != null && _englishTranslation != null)
          Container(
            height: 1,
            margin: EdgeInsets.symmetric(vertical: 8.h),
            color: const Color(0xFF1E5B30).withValues(alpha: 0.1),
          ),

        // English Translation (LTR)
        if (_englishTranslation != null) ...[
          Text(
            _englishTranslation!,
            textAlign: TextAlign.left,
            style: TextStyle(
              fontSize: 16.sp,
              height: 1.4,
              color: Colors.black.withValues(alpha: 0.7),
              fontWeight: FontWeight.w400,
            ),
          ),
        ],

        if (_urduTranslation == null && _englishTranslation == null && !_isLoadingEn && !_isLoadingUr)
          const Text(
            "Translations not found.",
            textAlign: TextAlign.center,
          ),
      ],
    );
  }
}
