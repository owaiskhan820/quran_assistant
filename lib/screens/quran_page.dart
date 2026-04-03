import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/widgets/mushaf_view.dart';
import 'package:my_perfect_quran/widgets/mushaf_header.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:my_perfect_quran/core/navigation/nav_controller.dart';

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => QuranPageState();
}

class QuranPageState extends State<QuranPage> {
  int currentPage = 1;
  final PageController _pageController = PageController();
  (int, int)? _highlightedAyah;

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
    final data = getPageData(currentPage);
    if (data.isEmpty) return "Unknown";
    final surahNum = data[0]['surah'];
    return "$surahNum. ${getSurahName(surahNum)}";
  }

  String get _currentJuzInfo {
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
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double headerH = 8.h * 2 + 12.sp + 0.5;

    final mainContent = Stack(
      children: [
        Positioned(
          top: headerH + 10.h,
          left: 11,
          right: 11,
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
              initialPage: 3,
              controller: _pageController,
              highlightedAyah: _highlightedAyah,
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                });
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
                  '$currentPage',
                  style: TextStyle(
                    color: const Color(0xFF1E5B30),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );

    return Scaffold(
  body: mainContent, // JUST USE THE CONTENT DIRECTLY
);
  }
}
