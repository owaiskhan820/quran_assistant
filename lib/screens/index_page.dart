import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:quran_assistant/core/navigation.dart';
import 'package:quran_assistant/core/navigation/nav_controller.dart';
import 'package:quran_assistant/screens/quran_page.dart';
import 'package:quran_assistant/core/theme/typography.dart';
import 'package:quran_assistant/core/services/settings_service.dart';
import 'package:quran_assistant/l10n/translation_constants.dart';
import 'package:quran_assistant/helpers/quran_navigation_helper.dart';


class IndexPage extends StatefulWidget {
  const IndexPage({super.key});

  @override
  State<IndexPage> createState() => _IndexPageState();
}

class _IndexPageState extends State<IndexPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = "";

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToPage(int page) {
    currentNavIndex.value = 0;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final state = quranPageKey.currentState;
      if (state is QuranPageState) {
        state.onSearchPage(page);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: SettingsService.instance.localeNotifier,
      builder: (context, lang, _) {
        final isUrdu = lang == 'ur';
        final textDirection = isUrdu ? TextDirection.rtl : TextDirection.ltr;
        final urduStyle = AppTypography.urduBase.copyWith(fontSize: 18.sp);

        return Directionality(
          textDirection: textDirection,
          child: DefaultTabController(
            length: 3,
            child: Scaffold(
              backgroundColor: const Color(0xFFF8F4ED),
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
                title: Text(
                  TranslationConstants.getString(lang, 'index'),
                  style: isUrdu 
                    ? urduStyle.copyWith(fontSize: 22.sp, fontWeight: FontWeight.bold)
                    : AppTypography.englishBase.copyWith(
                        color: const Color(0xFF1E5B30),
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(48.h),
                  child: TabBar(
                    indicatorColor: const Color(0xFF2C6B4A),
                    indicatorWeight: 3.h,
                    labelColor: const Color(0xFF2C6B4A),
                    unselectedLabelColor: Colors.grey.shade600,
                    labelStyle: TextStyle(
                      fontSize: isUrdu ? 16.sp : 14.sp, 
                      fontWeight: FontWeight.bold,
                      fontFamily: isUrdu ? AppTypography.urduFont : null,
                    ),
                    tabs: [
                      Tab(text: TranslationConstants.getString(lang, 'surah')),
                      Tab(text: TranslationConstants.getString(lang, 'para')),
                      Tab(text: TranslationConstants.getString(lang, 'page')),
                    ],
                  ),
                ),
              ),
              body: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.w, 15.h, 20.w, 10.h),
                    child: IndexSearchBar(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      hintText: TranslationConstants.getString(lang, 'search'),
                      isUrdu: isUrdu,
                    ),
                  ),
                  Expanded(
                    child: TabBarView(
                      children: [
                        _buildSurahList(lang, isUrdu, urduStyle),
                        _buildJuzList(lang, isUrdu, urduStyle),
                        _buildPageSearch(lang, isUrdu, urduStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSurahList(String lang, bool isUrdu, TextStyle urduStyle) {
    final List<int> filteredSurahs = List.generate(114, (i) => i + 1).where((s) {
      if (_searchQuery.isEmpty) return true;
      final name = getSurahName(s).toLowerCase();
      return name.contains(_searchQuery.toLowerCase()) || s.toString().contains(_searchQuery);
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: filteredSurahs.length,
      itemBuilder: (context, index) {
        final surahNum = filteredSurahs[index];
        final surahName = isUrdu 
          ? TranslationConstants.getString(lang, 'surah_$surahNum')
          : getSurahName(surahNum);
          
        return _buildIndexCard(
          index: isUrdu ? TranslationConstants.toUrduDigits(surahNum) : surahNum.toString(),
          title: surahName,
          subtitle: isUrdu 
            ? "${TranslationConstants.getString(lang, 'surahNo')} ${TranslationConstants.toUrduDigits(surahNum)}"
            : "Surah No. $surahNum",
          onTap: () {
            final page = QuranNavigationHelper.getPageNumber(surahNum, 1);
            _navigateToPage(page > 0 ? page : 1);
          },
          isUrdu: isUrdu,
          urduStyle: urduStyle,
        );
      },
    );
  }

  Widget _buildJuzList(String lang, bool isUrdu, TextStyle urduStyle) {
    final List<int> filteredJuz = List.generate(30, (i) => i + 1).where((j) {
      if (_searchQuery.isEmpty) return true;
      return j.toString().contains(_searchQuery) || 
             TranslationConstants.getString(lang, 'para').toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: filteredJuz.length,
      itemBuilder: (context, index) {
        final juzNum = filteredJuz[index];
        final startPage = _getJuzStartPage(juzNum);
        
        return _buildIndexCard(
          index: isUrdu ? TranslationConstants.toUrduDigits(juzNum) : juzNum.toString(),
          title: isUrdu 
            ? "${TranslationConstants.getString(lang, 'para')} ${TranslationConstants.toUrduDigits(juzNum)}"
            : "Juz $juzNum",
          subtitle: isUrdu 
            ? "${TranslationConstants.getString(lang, 'startsAt')} ${TranslationConstants.toUrduDigits(startPage)}"
            : "Starts at Page $startPage",
          onTap: () => _navigateToPage(startPage),
          isUrdu: isUrdu,
          urduStyle: urduStyle,
        );
      },
    );
  }

  Widget _buildPageSearch(String lang, bool isUrdu, TextStyle urduStyle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_rounded, size: 80.r, color: const Color(0xFF2C6B4A).withValues(alpha: 0.2)),
          SizedBox(height: 20.h),
          Text(
            TranslationConstants.getString(lang, 'enterPage'),
            style: isUrdu ? urduStyle : TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
          ),
          if (_searchQuery.isNotEmpty && int.tryParse(_searchQuery) != null)
            Padding(
              padding: EdgeInsets.only(top: 20.h),
              child: ElevatedButton(
                onPressed: () {
                  final p = int.tryParse(_searchQuery);
                  if (p != null && p >= 1 && p <= 604) {
                    _navigateToPage(p);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2C6B4A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
                ),
                child: Text(
                  isUrdu 
                    ? "${TranslationConstants.getString(lang, 'goToPage')} ${TranslationConstants.toUrduDigits(int.parse(_searchQuery))}"
                    : "Go to Page $_searchQuery",
                  style: isUrdu ? urduStyle.copyWith(color: Colors.white, fontSize: 14.sp) : null,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildIndexCard({
    required String index,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isUrdu = false,
    TextStyle? urduStyle,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
        leading: Container(
          width: 40.r,
          height: 40.r,
          decoration: BoxDecoration(
            color: const Color(0xFF2C6B4A).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Center(
            child: Text(
              index,
              style: TextStyle(
                color: const Color(0xFF2C6B4A),
                fontWeight: FontWeight.bold,
                fontSize: isUrdu ? 16.sp : 14.sp,
                fontFamily: isUrdu ? AppTypography.urduFont : null,
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: isUrdu 
            ? urduStyle?.copyWith(fontWeight: FontWeight.w600, color: Colors.black87)
            : TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
        ),
        subtitle: Text(
          subtitle,
          style: isUrdu 
            ? urduStyle?.copyWith(fontSize: 14.sp, color: Colors.grey.shade500)
            : TextStyle(
                fontSize: 12.sp,
                color: Colors.grey.shade500,
              ),
        ),
        trailing: Icon(
          isUrdu ? Icons.arrow_back_ios_rounded : Icons.arrow_forward_ios_rounded, 
          size: 16.r, 
          color: Colors.grey.shade400
        ),
      ),
    );
  }

  int _getJuzStartPage(int juz) {
    const juzStartPages = [
      1, 22, 42, 62, 82, 102, 122, 142, 162, 182,
      202, 222, 242, 262, 282, 302, 322, 342, 362, 382,
      402, 422, 442, 462, 482, 502, 522, 542, 562, 582
    ];
    return juzStartPages[juz - 1];
  }


}

class IndexSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final String hintText;
  final bool isUrdu;

  const IndexSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    this.hintText = 'Search...',
    this.isUrdu = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textAlign: isUrdu ? TextAlign.right : TextAlign.left,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade400, 
            fontSize: isUrdu ? 16.sp : 14.sp,
            fontFamily: isUrdu ? AppTypography.urduFont : null,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          suffixIcon: Icon(Icons.search, color: const Color(0xFF1E5B30), size: 22.r),
        ),
      ),
    );
  }
}
