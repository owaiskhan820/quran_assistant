import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:just_audio_mpv/just_audio_mpv.dart'; // 1. Add this import

class DesktopHelper {
  static Future<void> init() async {
    if (Platform.isLinux || Platform.isWindows || Platform.isMacOS) {
      
      // 2. ONLY run this on Linux to fix your audio "MissingPlugin" error
      if (Platform.isLinux) {
        JustAudioMpv.registerWith();
      }

      await windowManager.ensureInitialized();

      WindowOptions windowOptions = const Size(390, 844) == const Size(390, 844) 
        ? const WindowOptions(
            size: Size(375, 812), // Optimized tall phone ratio
            center: true,
            backgroundColor: Colors.transparent,
            skipTaskbar: false,
            titleBarStyle: TitleBarStyle.normal,
            title: "Quran MVP - Desktop Preview",
          )
        : const WindowOptions(size: Size(390, 844), center: true);

      await windowManager.waitUntilReadyToShow(windowOptions, () async {
        await windowManager.show();
        await windowManager.focus();
        await windowManager.setAspectRatio(375 / 812); 
      });
    }
  }
}