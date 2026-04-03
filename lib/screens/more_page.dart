import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:my_perfect_quran/core/services/settings_service.dart';
import 'package:my_perfect_quran/core/services/audio_service.dart';

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
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).primaryColor;
    final currentQariId = SettingsService.instance.qariId;
    final currentLang = SettingsService.instance.translationLang;

    return Scaffold(
      appBar: AppBar(
        title: const Text('More'),
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
            title: const Text('Default Reciter'),
            subtitle: Text(_getQariName(currentQariId)),
            onTap: _selectQari,
          ),
          ListTile(
            leading: Icon(Icons.translate, color: primaryColor),
            title: const Text('Translation Language'),
            trailing: Switch.adaptive(
              value: currentLang == 'ur',
              activeTrackColor: primaryColor,
              onChanged: (bool value) async {
                final newLang = value ? 'ur' : 'en';
                await SettingsService.instance.setTranslationLang(newLang);
                setState(() {});
              },
            ),
            subtitle: Text(currentLang == 'ur' ? 'Urdu' : 'English'),
          ),
          ListTile(
            leading: Icon(Icons.download_for_offline, color: primaryColor),
            title: const Text('Manage Translations'),
            subtitle: const Text('Download for offline use'),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: Icon(Icons.share, color: primaryColor),
            title: const Text('Share with others'),
            onTap: () => _showComingSoon(context),
          ),
          ListTile(
            leading: Icon(Icons.contact_support, color: primaryColor),
            title: const Text('Support & Feedback'),
            onTap: () => _showComingSoon(context),
          ),
        ],
      ),
    );
  }
}
