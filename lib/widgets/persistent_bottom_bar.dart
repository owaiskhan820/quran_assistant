import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/widgets/scan_camera_screen.dart';
import 'package:my_perfect_quran/core/navigation.dart';

class PersistentBottomBar extends StatefulWidget {
  const PersistentBottomBar({super.key});

  @override
  State<PersistentBottomBar> createState() => _PersistentBottomBarState();
}

class _PersistentBottomBarState extends State<PersistentBottomBar> {
  @override
  Widget build(BuildContext context) {
    final double keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    if (keyboardHeight > 0) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            height: 65.h,                    // Slightly taller for better spacing
            width: double.infinity,
            decoration: BoxDecoration(
              color: const Color(0xFFF8F9FA).withOpacity(0.92),
              border: Border(
                top: BorderSide(
                  color: Colors.black.withOpacity(0.08),
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Index
                _NavBarItem(
                  icon: Icons.menu_book_rounded,
                  label: "Index",
                  onTap: () => debugPrint("ACTION: Index tapped"),
                ),

                // Scan Ayah
                _NavBarItem(
                    icon: Icons.camera_alt_rounded,
                    label: "Scan",
                    onTap: () {
                      debugPrint("=== PLUMBING: Launching Unified Scan Screen ===");
                      navigatorKey.currentState?.push(
                        MaterialPageRoute(
                          builder: (context) => const ScanCameraScreen(),
                        ),
                      );
                    },
                  ),

                // Audio
                _NavBarItem(
                  icon: Icons.mic_rounded,
                  label: "Audio",
                  onTap: () {
                    debugPrint("=== AUDIO BUTTON TAPPED ===");
                    // TODO: Add your audio recording logic here later
                  },
                ),

                // Settings
                _NavBarItem(
                  icon: Icons.settings_rounded,
                  label: "Settings",
                  onTap: () => debugPrint("ACTION: Settings tapped"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ==================== REUSABLE NAV ITEM ====================
class _NavBarItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _NavBarItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        debugPrint("DEBUG: Tap registered on: $label");
        onTap();
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.grey.shade800, size: 24.r),
          SizedBox(height: 4.h),
          Text(
            label,
            style: TextStyle(
              color: Colors.grey.shade800,
              fontSize: 10.sp,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}