import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/core/services/audio_service.dart';
import 'package:my_perfect_quran/services/translation_service.dart';
import 'package:sliding_up_panel/sliding_up_panel.dart';

class AyahMediaPlayer extends StatefulWidget {
  final Widget? body;
  const AyahMediaPlayer({super.key, this.body});

  @override
  State<AyahMediaPlayer> createState() => _AyahMediaPlayerState();
}

class _AyahMediaPlayerState extends State<AyahMediaPlayer> {
  String? _translationText;
  final PanelController _panelController = PanelController();
  
  // Local state for dropdowns
  int _fromAyah = 1;
  int _toAyah = 7;
  String _selectedQari = "Mishary Rashid Alafasy";

  @override
  void initState() {
    super.initState();
    AudioService.instance.currentAyah.addListener(_updateTranslation);
    // Initialize ranges based on current service values
    _fromAyah = AudioService.instance.currentAyah.value ?? 1;
    _toAyah = _fromAyah;
  }

  @override
  void dispose() {
    AudioService.instance.currentAyah.removeListener(_updateTranslation);
    super.dispose();
  }

  void _updateTranslation() {
    final s = AudioService.instance.currentSurah.value;
    final a = AudioService.instance.currentAyah.value;
    if (s != null && a != null) {
      final translation = TranslationService.instance.getUrduTranslation(s, a);
      if (mounted) {
        setState(() {
          _translationText = translation;
          _fromAyah = a; // Sync dropdown with tapped ayah
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<int?>(
      valueListenable: AudioService.instance.currentAyah,
      builder: (context, ayah, _) {
        // If no ayah is active, show the normal Mushaf (body)
        if (ayah == null) return widget.body ?? const SizedBox.shrink();

        return SlidingUpPanel(
          controller: _panelController,
          maxHeight: 480.h,
          minHeight: 130.h,
          parallaxEnabled: true,
          parallaxOffset: .5,
          color: const Color(0xFFFBF1E6),
          borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
          panelBuilder: (sc) => _buildExpandedPanel(sc),
          collapsed: _buildCollapsedPanel(),
          body: widget.body, 
        );
      },
    );
  }

  Widget _buildCollapsedPanel() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFBF1E6),
        borderRadius: BorderRadius.vertical(top: Radius.circular(30.r)),
      ),
      child: Column(
        children: [
          SizedBox(height: 12.h),
          _buildHandle(),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: Icon(Icons.close, color: const Color(0xFF1E5B30), size: 24.sp),
                onPressed: () => AudioService.instance.stop(), 
              ),
              IconButton(
                icon: Icon(Icons.skip_previous, color: const Color(0xFF1E5B30), size: 28.sp),
                onPressed: () => AudioService.instance.playPrevious(),
              ),
              ValueListenableBuilder<bool>(
                valueListenable: AudioService.instance.isPlaying,
                builder: (context, isPlaying, _) {
                  return IconButton(
                    icon: Icon(
                      isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                      color: const Color(0xFF1E5B30),
                      size: 45.sp,
                    ),
                    onPressed: () => AudioService.instance.togglePlayPause(),
                  );
                },
              ),
              IconButton(
                icon: Icon(Icons.skip_next, color: const Color(0xFF1E5B30), size: 28.sp),
                onPressed: () => AudioService.instance.playNext(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildExpandedPanel(ScrollController sc) {
    return ListView(
      controller: sc,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      children: [
        SizedBox(height: 12.h),
        _buildHandle(),
        SizedBox(height: 25.h),
        
        // Urdu Translation Display
        if (_translationText != null)
          Text(
            _translationText!,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18.sp,
              color: const Color(0xFF1E5B30),
              fontFamily: 'UrduFont', 
            ),
          ),
        
        SizedBox(height: 30.h),
        
        // Range Selector Block
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Play a range of ayahs", style: _headerStyle()),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // FROM
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("From", style: TextStyle(fontSize: 11.sp, color: Colors.grey[500])),
                      SizedBox(height: 4.h),
                      _buildSimplePill(_fromAyah, (val) => setState(() => _fromAyah = val!)),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                // TO
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("To", style: TextStyle(fontSize: 11.sp, color: Colors.grey[500])),
                      SizedBox(height: 4.h),
                      _buildSimplePill(_toAyah, (val) => setState(() => _toAyah = val!)),
                    ],
                  ),
                ),
                SizedBox(width: 15.w),
                // PLAY BUTTON
                CircleAvatar(
                  radius: 24.r,
                  backgroundColor: const Color(0xFF1E5B30),
                  child: IconButton(
                    icon: const Icon(Icons.play_arrow, color: Colors.white),
                    onPressed: () => AudioService.instance.playRange(_fromAyah, _toAyah),
                  ),
                ),
              ],
            ),
          ],
        ),

        SizedBox(height: 25.h),
        Text("Choose Qari", style: _headerStyle()),
        SizedBox(height: 12.h),
        
        _buildQariDropdown(),
        
        SizedBox(height: 30.h),
        
        // Close Button
        TextButton.icon(
          onPressed: () => AudioService.instance.stop(),
          icon: const Icon(Icons.close, color: Colors.redAccent),
          label: const Text("Close Player", style: TextStyle(color: Colors.redAccent)),
        ),
      ],
    );
  }

  // --- Helper Widgets ---

  Widget _buildHandle() {
    return Center(
      child: Container(
        width: 40.w,
        height: 5.h,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  TextStyle _headerStyle() => TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w600, color: Colors.grey[600]);

  Widget _buildSimplePill(int value, ValueChanged<int?> onChanged) {
    // Note: In the next step, replace 286 with a dynamic count from your Quran service
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E0D5),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.arrow_drop_down, color: const Color(0xFF1E5B30)),
          items: List.generate(286, (index) => index + 1)
              .map((e) => DropdownMenuItem(value: e, child: Text("$e")))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildQariDropdown() {
    final qaris = ["Mishary Rashid Alafasy", "Abdul Basit", "Abdur-Rahman as-Sudais"];
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFE8E0D5),
        borderRadius: BorderRadius.circular(15.r),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedQari,
          isExpanded: true,
          items: qaris.map((q) => DropdownMenuItem(value: q, child: Text(q))).toList(),
          onChanged: (val) => setState(() => _selectedQari = val!),
        ),
      ),
    );
  }
}