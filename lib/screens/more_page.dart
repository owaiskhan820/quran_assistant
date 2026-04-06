import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quran_assistant/core/services/settings_service.dart';
import 'package:quran_assistant/core/services/audio_service.dart';
import 'package:quran_assistant/core/theme/typography.dart';
import 'package:quran_assistant/l10n/translation_constants.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  void _showComingSoon(BuildContext context, String currentLang) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          TranslationConstants.getString(currentLang, 'featureSoon'),
          style: currentLang == 'ur' ? AppTypography.urduBase.copyWith(fontSize: 14.sp) : null,
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  String _getLocalizedQariName(int id, String lang) {
    return TranslationConstants.getString(lang, 'qari_$id');
  }

  void _selectQari(String lang, bool isUrdu, TextStyle urduStyle) {
    showDialog(
      context: context,
      builder: (context) => Directionality(
        textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
        child: SimpleDialog(
          title: Text(
            TranslationConstants.getString(lang, 'selectQari'),
            style: isUrdu ? urduStyle.copyWith(fontWeight: FontWeight.bold) : null,
          ),
          children: AudioService.instance.qariMap.entries.map((entry) {
            return SimpleDialogOption(
              onPressed: () async {
                await SettingsService.instance.setQariId(entry.value);
                if (!context.mounted) return;
                setState(() {});
                Navigator.pop(context);
              },
              child: Text(
                _getLocalizedQariName(entry.value, lang),
                style: isUrdu ? urduStyle.copyWith(fontSize: 16.sp) : null,
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    SettingsService.instance.localeNotifier.addListener(_onLocaleChanged);
  }

  @override
  void dispose() {
    SettingsService.instance.localeNotifier.removeListener(_onLocaleChanged);
    super.dispose();
  }

  void _onLocaleChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final currentQariId = SettingsService.instance.qariId;
    
    return ValueListenableBuilder<String>(
      valueListenable: SettingsService.instance.localeNotifier,
      builder: (context, currentLang, _) {
        final isUrdu = currentLang == 'ur';
        final urduStyle = AppTypography.urduBase.copyWith(fontSize: 18.sp);
        final textDirection = isUrdu ? TextDirection.rtl : TextDirection.ltr;

        return Directionality(
          textDirection: textDirection,
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                TranslationConstants.getString(currentLang, 'more'),
                style: isUrdu
                    ? urduStyle.copyWith(fontWeight: FontWeight.bold)
                    : AppTypography.englishBase.copyWith(fontWeight: FontWeight.bold),
              ),
              centerTitle: true,
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              elevation: 0,
            ),
            backgroundColor: Colors.white,
            body: ListView(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              children: [
                ListTile(
                  leading: Icon(Icons.person_pin, color: primaryColor),
                  title: Text(
                    TranslationConstants.getString(currentLang, 'defaultQari'),
                    style: isUrdu ? urduStyle : null,
                  ),
                  subtitle: Text(
                    _getLocalizedQariName(currentQariId, currentLang),
                    style: isUrdu ? urduStyle.copyWith(fontSize: 14.sp) : null,
                  ),
                  onTap: () => _selectQari(currentLang, isUrdu, urduStyle),
                ),
                ListTile(
                  leading: Icon(Icons.translate, color: primaryColor),
                  title: Text(
                    'Language / زبان',
                    style: isUrdu ? urduStyle : null,
                  ),
                  trailing: Container(
                    width: 80.w,
                    height: 34.h,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(17.r),
                    ),
                    child: Stack(
                      children: [
                        AnimatedAlign(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeInOut,
                          alignment: currentLang == 'ur' ? Alignment.centerRight : Alignment.centerLeft,
                          child: Container(
                            width: 40.w,
                            height: 34.h,
                            decoration: BoxDecoration(
                              color: primaryColor,
                              borderRadius: BorderRadius.circular(17.r),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () => SettingsService.instance.setTranslationLang('en'),
                                child: Center(
                                  child: Text(
                                    'EN',
                                    style: TextStyle(
                                      color: currentLang == 'en' ? Colors.white : Colors.grey.shade600,
                                      fontSize: 12.sp,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () => SettingsService.instance.setTranslationLang('ur'),
                                child: Center(
                                  child: Text(
                                    'UR',
                                    style: TextStyle(
                                      color: currentLang == 'ur' ? Colors.white : Colors.grey.shade600,
                                      fontSize: 12.sp,
                                      fontFamily: AppTypography.urduFont,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  subtitle: Text(
                    currentLang == 'ur' ? 'اردو' : 'English',
                    style: isUrdu ? urduStyle.copyWith(fontSize: 14.sp) : null,
                  ),
                ),
                ListTile(
                  leading: Icon(Icons.download_for_offline, color: primaryColor),
                  title: Text(
                    TranslationConstants.getString(currentLang, 'manageTranslations'),
                    style: isUrdu ? urduStyle : null,
                  ),
                  subtitle: Text(
                    TranslationConstants.getString(currentLang, 'downloadOffline'),
                    style: isUrdu ? urduStyle.copyWith(fontSize: 14.sp) : null,
                  ),
                  onTap: () => _showComingSoon(context, currentLang),
                ),
                ListTile(
                  leading: Icon(Icons.share, color: primaryColor),
                  title: Text(
                    TranslationConstants.getString(currentLang, 'share'),
                    style: isUrdu ? urduStyle : null,
                  ),
                  onTap: () => _showComingSoon(context, currentLang),
                ),
                ListTile(
                  leading: Icon(Icons.contact_support, color: primaryColor),
                  title: Text(
                    TranslationConstants.getString(currentLang, 'support'),
                    style: isUrdu ? urduStyle : null,
                  ),
                  onTap: () => _showComingSoon(context, currentLang),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
