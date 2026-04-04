import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/core/services/settings_service.dart';
import 'package:my_perfect_quran/core/services/audio_service.dart';
import 'package:my_perfect_quran/core/theme/typography.dart';
import 'package:my_perfect_quran/l10n/translation_constants.dart';

class MorePage extends StatefulWidget {
  const MorePage({super.key});

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _getQariName(int id) {
    final qariMap = AudioService.instance.qariMap;
    return qariMap.entries
        .firstWhere((e) => e.value == id, orElse: () => qariMap.entries.first)
        .key;
  }

  void _selectQari() {
    showDialog(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Select Default Reciter'),
        children: AudioService.instance.qariMap.entries.map((entry) {
          return SimpleDialogOption(
            onPressed: () async {
              await SettingsService.instance.setQariId(entry.value);
              if (!context.mounted) return;
              setState(() {});
              Navigator.pop(context);
            },
            child: Text(entry.key),
          );
        }).toList(),
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
    final currentLang = SettingsService.instance.translationLang;

    final isUrdu = currentLang == 'ur';
    final urduStyle = AppTypography.urduBase.copyWith(fontSize: 18.sp);

    return Scaffold(
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
              _getQariName(currentQariId),
              style: isUrdu ? urduStyle.copyWith(fontSize: 14.sp) : null,
            ),
            onTap: _selectQari,
          ),
          ListTile(
            leading: Icon(Icons.translate, color: primaryColor),
            title: const Text('Language / زبان'),
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
              isUrdu ? 'ترجمے' : 'Manage Translations',
              style: isUrdu ? urduStyle : null,
            ),
            subtitle: Text(
              isUrdu ? 'آف لائن استعمال کے لیے' : 'Download for offline use',
              style: isUrdu ? urduStyle.copyWith(fontSize: 14.sp) : null,
            ),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: Icon(Icons.share, color: primaryColor),
            title: Text(
              isUrdu ? 'شیئر کریں' : 'Share with others',
              style: isUrdu ? urduStyle : null,
            ),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: Icon(Icons.contact_support, color: primaryColor),
            title: Text(
              isUrdu ? 'مدد اور تاثرات' : 'Support & Feedback',
              style: isUrdu ? urduStyle : null,
            ),
            onTap: () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }
}
