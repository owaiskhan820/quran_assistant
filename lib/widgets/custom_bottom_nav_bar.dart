import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/l10n/translation_constants.dart';
import 'package:my_perfect_quran/core/services/settings_service.dart';
import 'package:my_perfect_quran/core/theme/typography.dart';
import 'package:my_perfect_quran/core/navigation/nav_controller.dart';
import 'package:my_perfect_quran/widgets/scan_camera_screen.dart';
import 'package:my_perfect_quran/core/navigation.dart';

class CustomBottomNavBar extends StatelessWidget {
  const CustomBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SettingsService.instance.localeNotifier,
      builder: (context, currentLang, _) {
        final isUrdu = currentLang == 'ur';
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Visual Cue / Hide Indicator
            Container(
              width: 40.w,
              height: 3.h,
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            Container(
              margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 16.h),
              height: 65.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF8F4ED),
                borderRadius: BorderRadius.circular(30.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ValueListenableBuilder<int>(
                valueListenable: currentNavIndex,
                builder: (context, currentIndex, child) {
                  void safeSwitch(int index) {
                    Navigator.of(context).popUntil((route) => route.isFirst);
                    currentNavIndex.value = index;
                  }
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _NavBarItem(
                        icon: Icons.menu_book_rounded,
                        label: TranslationConstants.getString(currentLang, 'mushaf'),
                        isSelected: currentIndex == 0,
                        onTap: () => safeSwitch(0),
                        isUrdu: isUrdu,
                      ),
                      _NavBarItem(
                        icon: Icons.list_alt_rounded,
                        label: TranslationConstants.getString(currentLang, 'index'),
                        isSelected: currentIndex == 1,
                        onTap: () => safeSwitch(1),
                        isUrdu: isUrdu,
                      ),
                      _NavBarItem(
                        icon: Icons.camera_alt_rounded,
                        label: TranslationConstants.getString(currentLang, 'scan'),
                        isSelected: currentIndex == 2,
                        onTap: () {
                          Navigator.of(context).popUntil((route) => route.isFirst);
                          navigatorKey.currentState?.push(
                            MaterialPageRoute(
                              builder: (context) => const ScanCameraScreen(),
                            ),
                          );
                        },
                        isUrdu: isUrdu,
                      ),
                      _NavBarItem(
                        icon: Icons.more_horiz_rounded,
                        label: TranslationConstants.getString(currentLang, 'more'),
                        isSelected: currentIndex == 2,
                        onTap: () => safeSwitch(2),
                        isUrdu: isUrdu,
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}

class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final bool isUrdu;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.isUrdu = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? Colors.black : Colors.grey.shade600;
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20.r),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24.r),
            SizedBox(height: isUrdu ? 0 : 4.h),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: isUrdu ? 12.sp : 10.sp,
                fontFamily: isUrdu ? AppTypography.urduFont : AppTypography.englishFont,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                height: isUrdu ? 1.0 : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
