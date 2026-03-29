import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'interactive_qcf_page.dart';

class InteractivePageviewQuran extends StatefulWidget {
  final int initialPageNumber;
  final PageController? controller;
  final double sp;
  final double h;
  final ValueChanged<int>? onPageChanged;
  final double? fontSize;
  final QcfThemeData? theme;
  final Color textColor;
  final Color pageBackgroundColor;
  final ScrollPhysics? physics;
  
  final void Function(int surah, int verse, String word, String font, int wordIndex)? onWordTap;
  final void Function(int surah, int verse)? onAyahTap;
  final void Function(int surah, int verse)? onAyahLongPress;

  const InteractivePageviewQuran({
    super.key,
    this.initialPageNumber = 1,
    this.controller,
    this.onPageChanged,
    this.fontSize,
    this.sp = 0.9,
    this.h = 1.05,
    this.theme,
    this.textColor = const Color(0xFF000000),
    this.pageBackgroundColor = const Color(0xFFFFFFFF),
    this.physics,
    this.onWordTap,
    this.onAyahTap,
    this.onAyahLongPress,
  }) : assert(initialPageNumber >= 1 && initialPageNumber <= 604);

  @override
  State<InteractivePageviewQuran> createState() => _InteractivePageviewQuranState();
}

class _InteractivePageviewQuranState extends State<InteractivePageviewQuran> {
  PageController? _internalController;
  PageController get _controller => widget.controller ?? _internalController!;
  bool get _ownsController => widget.controller == null;

  @override
  void initState() {
    super.initState();
    if (_ownsController) {
      _internalController = PageController(
        initialPage: widget.initialPageNumber - 1,
      );
    }
  }

  @override
  void dispose() {
    if (_ownsController) {
      _internalController?.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.theme ?? const QcfThemeData();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        color: widget.theme?.pageBackgroundColor ?? widget.pageBackgroundColor,
        child: SizedBox.expand(
          child: PageView.builder(
            physics: widget.physics,
            controller: _controller,
            reverse: false,
            itemCount: 604,
            onPageChanged: (index) => widget.onPageChanged?.call(index + 1),
            itemBuilder: (context, index) {
              final pageNumber = index + 1;
              return InteractiveQcfPage(
                pageNumber: pageNumber,
                fontSize: widget.fontSize,
                onWordTap: widget.onWordTap,
                onAyahTap: widget.onAyahTap,
                sp: widget.sp,
                h: widget.h,
                theme: effectiveTheme,
              );
            },
          ),
        ),
      ),
    );
  }
}
