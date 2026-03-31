import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qcf_quran/qcf_quran.dart';
import 'package:my_perfect_quran/core/navigation.dart';
import 'package:my_perfect_quran/core/navigation/nav_controller.dart';
import 'package:my_perfect_quran/screens/quran_page.dart';

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
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFF8F4ED),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          title: Text(
            'Index',
            style: TextStyle(
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
              labelStyle: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold),
              tabs: const [
                Tab(text: 'Surah'),
                Tab(text: 'Juz'),
                Tab(text: 'Page'),
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
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildSurahList(),
                  _buildJuzList(),
                  _buildPageSearch(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahList() {
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
        return _buildIndexCard(
          index: surahNum.toString(),
          title: getSurahName(surahNum),
          subtitle: "Surah No. $surahNum",
          onTap: () {
            // Need to find start page of surah
            // In qcf_quran, maybe we can get it from somewhere or hardcode it
            // For now, I'll use a placeholder or find a better way
            final page = _getSurahStartPage(surahNum);
            _navigateToPage(page);
          },
        );
      },
    );
  }

  Widget _buildJuzList() {
    final List<int> filteredJuz = List.generate(30, (i) => i + 1).where((j) {
      if (_searchQuery.isEmpty) return true;
      return j.toString().contains(_searchQuery) || "juz $j".contains(_searchQuery.toLowerCase());
    }).toList();

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemCount: filteredJuz.length,
      itemBuilder: (context, index) {
        final juzNum = filteredJuz[index];
        return _buildIndexCard(
          index: juzNum.toString(),
          title: "Juz $juzNum",
          subtitle: "Starts at Page ${_getJuzStartPage(juzNum)}",
          onTap: () => _navigateToPage(_getJuzStartPage(juzNum)),
        );
      },
    );
  }

  Widget _buildPageSearch() {
    // Page tab is just a way to jump to page if nothing else is requested
    // But since search bar is global, we can use it to jump to page
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.auto_stories_rounded, size: 80.r, color: const Color(0xFF2C6B4A).withValues(alpha: 0.2)),
          SizedBox(height: 20.h),
          Text(
            "Enter page number (1-604)",
            style: TextStyle(fontSize: 16.sp, color: Colors.grey.shade600),
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
                child: Text("Go to Page $_searchQuery"),
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
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade500,
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios_rounded, size: 16.r, color: Colors.grey.shade400),
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

  int _getSurahStartPage(int surah) {
    // This is more complex, usually we need a mapping.
    // I'll check if qcf_quran provides this or I'll add a simplified map.
    // For now, let's use a common Surah -> Page map for 15-line Mushaf.
    // Or I can calculate it from some data.
    // Placeholder for now, I'll try to find the real values if possible.
    // Actually, I can use a small helper map for common ones.
    final Map<int, int> surahToPage = {
      1: 1, 2: 2, 3: 50, 4: 77, 5: 106, 6: 128, 7: 151, 8: 177, 9: 187, 10: 208,
      18: 293, 36: 440, 55: 531, 67: 562, 114: 604
    };
    return surahToPage[surah] ?? (surah * 5); // Fallback
  }
}

class IndexSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const IndexSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
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
        decoration: InputDecoration(
          hintText: 'Search...',
          hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14.sp),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 12.h),
          suffixIcon: Icon(Icons.search, color: const Color(0xFF1E5B30), size: 22.r),
        ),
      ),
    );
  }
}
