import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:qcf_quran/qcf_quran.dart';

class InteractiveQcfPage extends StatefulWidget {
  final int pageNumber;
  final QcfThemeData theme;
  final double? fontSize;
  final double sp;
  final double h;
  final void Function(int surah, int verse, String word, String font, int wordIndex)? onWordTap;
  final void Function(int surah, int verse)? onAyahTap;
  final void Function(int surah, int verse)? onAyahLongPress;

  const InteractiveQcfPage({
    super.key,
    required this.pageNumber,
    this.theme = const QcfThemeData(),
    this.fontSize,
    this.sp = 1.0,
    this.h = 1.0,
    this.onWordTap,
    this.onAyahTap,
    this.onAyahLongPress,
  });

  @override
  State<InteractiveQcfPage> createState() => _InteractiveQcfPageState();
}

class _InteractiveQcfPageState extends State<InteractiveQcfPage> {
  List<InlineSpan>? _cachedSpans;
  late String _pageFont;
  late double _baseFontSize;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initData();
  }

  @override
  void didUpdateWidget(InteractiveQcfPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.pageNumber != widget.pageNumber ||
        oldWidget.sp != widget.sp ||
        oldWidget.h != widget.h ||
        oldWidget.theme != widget.theme) {
      _cachedSpans = null;
      _initData();
    }
  }

  void _initData() {
    _pageFont = "QCF_P${widget.pageNumber.toString().padLeft(3, '0')}";
    _baseFontSize = getFontSize(widget.pageNumber, context) * widget.sp;
    if (_cachedSpans == null) {
      _cachedSpans = _buildSpans();
    }
  }

  List<InlineSpan> _buildSpans() {
    final ranges = getPageData(widget.pageNumber);
    final screenSize = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;
    final verseSpans = <InlineSpan>[];

    // Add top padding for first two pages (traditional layout)
    if (widget.pageNumber == 2 || widget.pageNumber == 1) {
      verseSpans.add(
        WidgetSpan(child: SizedBox(height: screenSize.height * .175)),
      );
    }

    for (final r in ranges) {
      final surah = int.parse(r['surah'].toString());
      final start = int.parse(r['start'].toString());
      final end = int.parse(r['end'].toString());

      for (int v = start; v <= end; v++) {
        // 1. Header and Basmala logic
        if (v == start && v == 1) {
          if (widget.theme.showHeader) {
            verseSpans.add(
              WidgetSpan(child: HeaderWidget(suraNumber: surah, theme: widget.theme)),
            );
          }
          if (widget.theme.showBasmala && widget.pageNumber != 1 && widget.pageNumber != 187) {
            if (widget.theme.basmalaBuilder != null) {
              verseSpans.add(
                WidgetSpan(
                  child: widget.theme.basmalaBuilder!(surah),
                  alignment: PlaceholderAlignment.middle,
                ),
              );
              verseSpans.add(const TextSpan(text: "\n"));
            } else {
              final basmalaText = " ﱁ  ﱂﱃﱄ";
              final basmalaWords = basmalaText.trim().split(RegExp(r'\s+'));
              final List<InlineSpan> basmalaSpans = [];
              for (int i = 0; i < basmalaWords.length; i++) {
                final w = basmalaWords[i];
                basmalaSpans.add(
                  TextSpan(
                    text: w,
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        widget.onWordTap?.call(surah, 0, w, "QCF_P001", i + 1);
                      },
                  ),
                );
                if (i < basmalaWords.length - 1) basmalaSpans.add(const TextSpan(text: ' '));
              }
              basmalaSpans.add(const TextSpan(text: "\n"));

              verseSpans.add(
                TextSpan(
                  children: basmalaSpans,
                  style: TextStyle(
                    fontFamily: "QCF_P001",
                    package: 'qcf_quran',
                    fontSize: getScreenType(context) == ScreenType.large
                        ? widget.theme.basmalaFontSizeLarge * widget.sp
                        : widget.theme.basmalaFontSizeSmall * widget.sp,
                    color: widget.theme.basmalaColor,
                  ),
                ),
              );
            }
          }
        }

        // 2. Word-by-word text rendering
        String verseText = getVerseQCF(surah, v, verseEndSymbol: false);
        final charList = verseText.replaceAll(RegExp(r'\s+'), '').split('');
        for (int i = 0; i < charList.length; i++) {
          final word = charList[i];
          final wordIndex = i + 1;

          verseSpans.add(
            TextSpan(
              text: word,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  widget.onWordTap?.call(surah, v, word, _pageFont, wordIndex);
                },
              style: TextStyle(
                backgroundColor: widget.theme.verseBackgroundColor?.call(surah, v),
              ),
              children: [
                if (i < charList.length - 1) 
                  TextSpan(
                    text: ' ',
                    style: TextStyle(
                      backgroundColor: widget.theme.verseBackgroundColor?.call(surah, v),
                    ),
                  ),
              ],
            ),
          );
        }

        // 3. Ayah End Sign (Verse Number)
        InlineSpan verseNumberSpan;
        final verseNumGlyph = getVerseNumberQCF(surah, v);

        if (widget.theme.verseNumberBuilder != null) {
          verseNumberSpan = widget.theme.verseNumberBuilder!(surah, v, verseNumGlyph);
        } else {
          verseNumberSpan = WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            child: GestureDetector(
              onTap: () => widget.onAyahTap?.call(surah, v),
              onLongPress: () => widget.onAyahLongPress?.call(surah, v),
              child: Text(
                verseNumGlyph,
                style: TextStyle(
                  fontFamily: _pageFont,
                  package: 'qcf_quran',
                  color: widget.theme.verseNumberColor,
                  fontSize: isPortrait ? _baseFontSize : _baseFontSize,
                  height: widget.theme.verseNumberHeight * widget.h,
                  backgroundColor: widget.theme.verseBackgroundColor?.call(surah, v),
                ),
              ),
            ),
          );
        }

        verseSpans.add(
          TextSpan(
            text: ' ',
            style: TextStyle(
              backgroundColor: widget.theme.verseBackgroundColor?.call(surah, v),
            ),
          ),
        );
        verseSpans.add(verseNumberSpan);
        verseSpans.add(
          TextSpan(
            text: ' ',
            style: TextStyle(
              backgroundColor: widget.theme.verseBackgroundColor?.call(surah, v),
            ),
          ),
        );
      }
    }
    return verseSpans;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.pageNumber < 1 || widget.pageNumber > 604) {
      return Center(child: Text('Invalid page number: ${widget.pageNumber}'));
    }

    final screenSize = MediaQuery.of(context).size;
    final isPortrait = MediaQuery.of(context).orientation == Orientation.portrait;

    return SingleChildScrollView(
      child: SizedBox(
        height: screenSize.height,
        width: screenSize.width,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Text.rich(
            TextSpan(children: _cachedSpans ?? []),
            locale: const Locale("ar"),
            textAlign: TextAlign.center,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: _pageFont,
              package: 'qcf_quran',
              fontSize: isPortrait
                  ? _baseFontSize
                  : (widget.pageNumber == 1 || widget.pageNumber == 2)
                      ? 20 * widget.sp
                      : _baseFontSize - (17 * widget.sp),
              color: widget.theme.verseTextColor,
              height: isPortrait
                  ? (widget.pageNumber == 1 || widget.pageNumber == 2)
                      ? 2.2 * widget.h
                      : widget.theme.verseHeight * widget.h
                  : 4 * widget.h,
              letterSpacing: widget.theme.letterSpacing,
              wordSpacing: widget.theme.wordSpacing,
            ),
          ),
        ),
      ),
    );
  }
}
