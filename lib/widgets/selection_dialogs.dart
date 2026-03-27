import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:qcf_quran/qcf_quran.dart';

class SurahSelectionDialog extends StatefulWidget {
  const SurahSelectionDialog({super.key});

  @override
  State<SurahSelectionDialog> createState() => _SurahSelectionDialogState();
}

class _SurahSelectionDialogState extends State<SurahSelectionDialog> {
  String _searchQuery = "";

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: 0.8.sw,
        height: 0.8.sh,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              "Select Surah",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E5B30),
              ),
            ),
            SizedBox(height: 16.h),
            TextField(
              decoration: InputDecoration(
                hintText: "Search Surah...",
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                contentPadding: EdgeInsets.symmetric(vertical: 8.h),
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: ListView.separated(
                itemCount: 114,
                separatorBuilder: (context, index) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final surahNumber = index + 1;
                  final name = getSurahName(surahNumber);
                  final englishName = getSurahNameEnglish(surahNumber);
                  final arabicName = getSurahNameArabic(surahNumber);
                  final startPage = getPageNumber(surahNumber, 1);

                  if (_searchQuery.isNotEmpty &&
                      !name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                      !englishName.toLowerCase().contains(_searchQuery.toLowerCase()) &&
                      !arabicName.contains(_searchQuery)) {
                    return const SizedBox.shrink();
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF1E5B30),
                      radius: 16.r,
                      child: Text(
                        surahNumber.toString(),
                        style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(name)),
                        Text(
                          String.fromCharCode(surahNumber),
                          style: TextStyle(
                            fontSize: 24.sp,
                            fontFamily: 'surahname',
                            package: 'qcf_quran',
                            color: const Color(0xFF1E5B30),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Text(englishName),
                    trailing: Text(
                      "p. $startPage",
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                    onTap: () => Navigator.of(context).pop(startPage),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class JuzSelectionDialog extends StatelessWidget {
  const JuzSelectionDialog({super.key});

  // Start pages for Juz in standard 15-line Madani Mushaf
  static const juzStartPages = [
    1, 22, 42, 62, 82, 102, 122, 142, 162, 182,
    202, 222, 242, 262, 282, 302, 322, 342, 362, 382,
    402, 422, 442, 462, 482, 502, 522, 542, 562, 582
  ];

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Container(
        width: 0.6.sw,
        height: 0.7.sh,
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            Text(
              "Select Juz",
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1E5B30),
              ),
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 12.h,
                  crossAxisSpacing: 12.w,
                  childAspectRatio: 1.1,
                ),
                itemCount: 30,
                itemBuilder: (context, index) {
                  final juzNumber = index + 1;
                  final startPage = juzStartPages[index];

                  return InkWell(
                    onTap: () => Navigator.of(context).pop(startPage),
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1E5B30)),
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      child: FittedBox( // Added
                        fit: BoxFit.scaleDown,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Juz",
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            Text(
                              juzNumber.toString(),
                              style: TextStyle(
                                fontSize: 18.sp,
                                fontWeight: FontWeight.bold,
                                color: const Color(0xFF1E5B30),
                              ),
                            ),
                            Text(
                              "p. $startPage",
                              style: TextStyle(fontSize: 10.sp, color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
