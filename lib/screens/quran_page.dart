import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_assistant/widgets/mushaf_view.dart';
import 'package:quran_assistant/widgets/mushaf_header.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:quran_assistant/core/navigation/nav_controller.dart';
import 'package:quran_assistant/core/services/settings_service.dart';
import 'package:quran_assistant/l10n/translation_constants.dart';
import 'package:quran_assistant/core/theme/typography.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => QuranPageState();
}

class QuranPageState extends State<QuranPage> {
  late int currentPage;
  late PageController _pageController;
  (int, int)? _highlightedAyah;

  @override
  void initState() {
    super.initState();
    currentPage = SettingsService.instance.getLastPage();
    _pageController = PageController(initialPage: currentPage - 1);
    SettingsService.instance.localeNotifier.addListener(_onLocaleChanged);
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  void onSearchPage(int page) {
    if (page < 1 || page > 604) return;
    _pageController.jumpToPage(page - 1);
    setState(() {
      currentPage = page;
      _highlightedAyah = null; // Clear highlight on page jump unless specified
    });
  }

  void onHighlightAyah(int surah, int ayah) {
    setState(() {
      _highlightedAyah = (surah, ayah);
    });
  }

  String get _currentSurahName {
    final lang = SettingsService.instance.translationLang;
    final data = getPageData(currentPage);
    if (data.isEmpty) return "Unknown";
    final surahNum = data[0]['surah'];
    
    if (lang == 'ur') {
      final urduName = TranslationConstants.getString(lang, 'surah_$surahNum');
      final urduNum = TranslationConstants.toUrduDigits(surahNum);
      return "$urduNum. $urduName";
    }
    return "$surahNum. ${getSurahName(surahNum)}";
  }

  String get _currentJuzInfo {
    final lang = SettingsService.instance.translationLang;
    const juzStartPages = [
      1, 22, 42, 62, 82, 102, 122, 142, 162, 182,
      202, 222, 242, 262, 282, 302, 322, 342, 362, 382,
      402, 422, 442, 462, 482, 502, 522, 542, 562, 582
    ];
    int currentJuz = 1;
    for (int i = 0; i < juzStartPages.length; i++) {
      if (currentPage >= juzStartPages[i]) {
        currentJuz = i + 1;
      }
    }
    
    if (lang == 'ur') {
      final paraLabel = TranslationConstants.getString(lang, 'para');
      final paraNum = TranslationConstants.toUrduDigits(currentJuz);
      return "$paraLabel $paraNum";
    }
    return "Juz $currentJuz";
  }

  void onSearchAndHighlight(int page, int surah, int ayah) {
    _pageController.jumpToPage(page - 1);
    setState(() {
      currentPage = page;
      _highlightedAyah = (surah, ayah);
    });
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        setState(() => _highlightedAyah = null);
      }
    });
  }

  @override
  void dispose() {
    SettingsService.instance.localeNotifier.removeListener(_onLocaleChanged);
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double headerH = 8.h * 2 + 12.sp + 0.5;

    final mainContent = Stack(
      children: [
        Positioned(
          top: headerH + 20.h,
          left: 12,
          right: 12,
          bottom: 0,
          child: GestureDetector(
            behavior: HitTestBehavior.translucent,
            onVerticalDragUpdate: (details) {
              // Weighted swipe: primaryDelta > 10 for down, < -10 for up
              if (details.primaryDelta! > 10) {
                showBottomNavNotifier.value = false;
              } else if (details.primaryDelta! < -10) {
                showBottomNavNotifier.value = true;
              }
            },
            onTap: () {
              // Optional: You could still have a tap-to-hide if desired, 
              // but the requirement specifies swipe. Keeping it for now as a fallback.
              showBottomNavNotifier.value = false;
            },
            child: MushafView(
              initialPage: currentPage,
              controller: _pageController,
              highlightedAyah: _highlightedAyah,
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                });
                SettingsService.instance.setLastPage(page);
              },
              onAyahLongPress: (surah, ayah) {
                showBottomNavNotifier.value = true;
                setState(() => _highlightedAyah = (surah, ayah));
              },
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MushafHeader(
            surahName: _currentSurahName,
            juzInfo: _currentJuzInfo,
            onSearchPage: onSearchPage,
            onSurahTap: () => currentNavIndex.value = 1,
            onJuzTap: () => currentNavIndex.value = 1,
          ),
        ),
        // Bottom-center page number pill
        Positioned(
          bottom: 12.h,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () => currentNavIndex.value = 1,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Text(
                  SettingsService.instance.translationLang == 'ur' 
                      ? TranslationConstants.toUrduDigits(currentPage) 
                      : '$currentPage',
                  style: TextStyle(
                    color: const Color(0xFF1E5B30),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    fontFamily: SettingsService.instance.translationLang == 'ur' 
                        ? AppTypography.urduFont 
                        : null,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: mainContent,
      ),
    );
  }
}
