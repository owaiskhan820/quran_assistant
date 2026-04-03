import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/helpers/desktop_helper.dart';
import 'package:my_perfect_quran/services/ai_service.dart';
import 'package:my_perfect_quran/core/navigation.dart';
import 'package:my_perfect_quran/core/navigation/nav_controller.dart';
import 'package:my_perfect_quran/screens/quran_page.dart';
import 'package:my_perfect_quran/screens/index_page.dart';
import 'package:my_perfect_quran/widgets/custom_bottom_nav_bar.dart';
import 'package:my_perfect_quran/services/translation_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize desktop settings (ignored on mobile)
  await DesktopHelper.init();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");

  // Initialize AIService
  AIService().init();
  
  await TranslationService.instance.loadLocalTranslations();

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
              const Center(child: Text('More')),
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
              child: SafeArea(
                top: false,
                child: const Wrap(
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