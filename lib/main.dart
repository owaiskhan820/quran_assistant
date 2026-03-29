import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/widgets/mushaf_view.dart';
import 'package:my_perfect_quran/widgets/mushaf_header.dart';
import 'package:my_perfect_quran/widgets/selection_dialogs.dart'; 
import 'package:my_perfect_quran/widgets/ayah_media_player.dart';
import 'package:my_perfect_quran/helpers/desktop_helper.dart';
import 'package:my_perfect_quran/widgets/persistent_bottom_bar.dart';
import 'package:my_perfect_quran/services/ai_service.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:my_perfect_quran/core/navigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize desktop settings (ignored on mobile)
  await DesktopHelper.init();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize AIService
  AIService().init();

  runApp(const MyQuranApp());
}

class MyQuranApp extends StatefulWidget {
  const MyQuranApp({super.key});

  @override
  State<MyQuranApp> createState() => _MyQuranAppState();
}

class _MyQuranAppState extends State<MyQuranApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          scrollBehavior: Platform.isLinux
              ? const MaterialScrollBehavior().copyWith(scrollbars: false)
              : null,
          builder: (context, child) {
            return Stack(
              children: [
                if (child != null) child,
                // Bar is now permanently visible and doesn't hide
                const Align(
                  alignment: Alignment.bottomCenter,
                  child: PersistentBottomBar(),
                ),
              ],
            );
          },
          home: QuranPage(key: quranPageKey),
        );
      },
    );
  }
}

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
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
    return "${surahNum}. ${getSurahName(surahNum)}";
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
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final double headerH = 8.h * 2 + 14.sp + 0.5;

    final mainContent = Stack(
      children: [
        Positioned(
          top: headerH,
          left: 0,
          right: 0,
          bottom: 0,
          child: GestureDetector(
            onTap: () {
              if (_highlightedAyah != null) {
                setState(() => _highlightedAyah = null);
              }
            },
            child: MushafView(
              initialPage: 1,
              controller: _pageController,
              highlightedAyah: _highlightedAyah,
              onPageChanged: (page) {
                setState(() {
                  currentPage = page;
                });
              },
              onAyahLongPress: (surah, ayah) {
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
            pageNumber: currentPage,
            surahName: _currentSurahName,
            juzInfo: _currentJuzInfo,
            onSearchPage: onSearchPage,
            onSurahTap: () async {
              final result = await showDialog<int>(
                context: context,
                builder: (_) => const SurahSelectionDialog(),
              );
              if (result != null) onSearchPage(result);
            },
            onJuzTap: () async {
              final result = await showDialog<int>(
                context: context,
                builder: (_) => const JuzSelectionDialog(),
              );
              if (result != null) onSearchPage(result);
            },
          ),
        ),
      ],
    );

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: AyahMediaPlayer(body: mainContent),
      ),
    );
  }
}