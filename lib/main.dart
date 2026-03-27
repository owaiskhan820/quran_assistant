import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/widgets/mushaf_view.dart';
import 'package:my_perfect_quran/widgets/mushaf_header.dart';
import 'package:my_perfect_quran/widgets/selection_dialogs.dart'; // Import selection dialogs
import 'package:my_perfect_quran/widgets/ayah_media_player.dart';
import 'package:my_perfect_quran/helpers/desktop_helper.dart';
import 'package:qcf_quran/qcf_quran.dart'; // Import package for data

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize desktop settings (ignored on mobile)
  await DesktopHelper.init();

  runApp(const MyQuranApp());
}
class MyQuranApp extends StatelessWidget {
  const MyQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          scrollBehavior: Platform.isLinux
              ? const MaterialScrollBehavior().copyWith(scrollbars: false)
              : null,
          home: const QuranPage(),
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

  void _onSearchPage(int page) {
    if (page < 1 || page > 604) return;
    _pageController.jumpToPage(page - 1);
    setState(() => currentPage = page);
  }

  String get _currentSurahName {
    // Page index to surah number from package data
    final data = getPageData(currentPage);
    if (data.isEmpty) return "Unknown";
    final surahNum = data[0]['surah'];
    return "${surahNum}. ${getSurahName(surahNum)}";
  }

  String get _currentJuzInfo {
    // We can use the juzStartPages from SelectionDialogs or calculate
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

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Header height: vertical padding (8.h * 2) + text (14.sp) + border (0.5)
    // We measure it safely from the design system
    final double headerH = 8.h * 2 + 14.sp + 0.5;

    final mainContent = Stack(
      children: [
        // 1. THE MUSHAF VIEW — starts below the header, fills the rest
        Positioned(
          top: headerH,
          left: 0,
          right: 0,
          bottom: 0,
          child: MushafView(
            initialPage: 1,
            controller: _pageController,
            onPageChanged: (page) {
              setState(() {
                currentPage = page;
              });
              debugPrint("Current Page: $page");
            },
          ),
        ),

        // 2. THE HEADER — floats at the top
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: MushafHeader(
            pageNumber: currentPage,
            surahName: _currentSurahName,
            juzInfo: _currentJuzInfo,
            onSearchPage: _onSearchPage,
            onSurahTap: () async {
              final result = await showDialog<int>(
                context: context,
                builder: (_) => const SurahSelectionDialog(),
              );
              if (result != null) _onSearchPage(result);
            },
            onJuzTap: () async {
              final result = await showDialog<int>(
                context: context,
                builder: (_) => const JuzSelectionDialog(),
              );
              if (result != null) _onSearchPage(result);
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