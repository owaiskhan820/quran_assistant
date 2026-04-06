import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_assistant/helpers/desktop_helper.dart';
import 'package:quran_assistant/services/ai_service.dart';
import 'package:quran_assistant/core/navigation.dart';
import 'package:quran_assistant/core/navigation/nav_controller.dart';
import 'package:quran_assistant/screens/quran_page.dart';
import 'package:quran_assistant/screens/index_page.dart';
import 'package:quran_assistant/screens/more_page.dart';
import 'package:quran_assistant/widgets/custom_bottom_nav_bar.dart';
import 'package:quran_assistant/services/translation_service.dart';
import 'package:quran_assistant/core/services/settings_service.dart';
import 'package:quran_assistant/core/theme/typography.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Preferences
  await SettingsService.instance.init();
  
  // Initialize desktop settings (ignored on mobile)
  await DesktopHelper.init();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize AIService
  AIService().init();
  
  await TranslationService.instance.loadLocalTranslations();

  runApp(const QuranAssistantApp());
}

class QuranAssistantApp extends StatefulWidget {
  const QuranAssistantApp({super.key});

  @override
  State<QuranAssistantApp> createState() => _QuranAssistantAppState();
}

class _QuranAssistantAppState extends State<QuranAssistantApp> {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      builder: (context, child) {
        return MaterialApp(
          title: 'Quran Assistant',
          navigatorKey: navigatorKey,
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            fontFamily: AppTypography.englishFont,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF1E5B30),
              primary: const Color(0xFF1E5B30),
            ),
            scaffoldBackgroundColor: Colors.white,
          ),
          scrollBehavior: Platform.isLinux
              ? const MaterialScrollBehavior().copyWith(scrollbars: false)
              : null,
          home: const MainNavigationShell(),
        );
      },
    );
  }
}

class MainNavigationShell extends StatelessWidget {
  const MainNavigationShell({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,
      backgroundColor: Colors.white,
      body: ValueListenableBuilder<int>(
        valueListenable: currentNavIndex,
        builder: (context, currentIndex, child) {
          return IndexedStack(
            index: currentIndex,
            children: [
              QuranPage(key: quranPageKey),
              const IndexPage(),
              const MorePage(),
            ],
          );
        },
      ),
      bottomNavigationBar: AnimatedBuilder(
        animation: Listenable.merge([showBottomNavNotifier, currentNavIndex]),
        builder: (context, child) {
          final showNav = showBottomNavNotifier.value || currentNavIndex.value != 0;
          return AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: showNav ? 1.0 : 0.0,
            curve: Curves.easeInOut,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: showNav ? (65.h + 24.h) : 0, // Increased slightly for SafeArea
              curve: Curves.easeInOut,
              child: const SafeArea(
                top: false,
                child: Wrap(
                  children: [
                    CustomBottomNavBar(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}