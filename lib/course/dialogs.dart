import 'package:flutter/material.dart';
import 'package:string_similarity/string_similarity.dart';

class CourseDialogs {
  static List<Map<String, dynamic>> courseData = []; // 用於存儲課程資料
  static final List<String> _bestMatches = []; // 用於存儲最佳匹配課程
  static List<List<String>> _gridTexts = []; // 假設這是用來存儲輸入的文本

  static void setCourseData(List<Map<String, dynamic>> data) {
    courseData = data; // 設置課程資料
  }

  static List<String> get bestMatches => _bestMatches; // 添加 getter

  static void matchCourses(List<List<String>> gridTexts) {
    _gridTexts = gridTexts; // 設置輸入文本

    if (_gridTexts.isNotEmpty && _gridTexts[0].isEmpty) {
      _bestMatches.clear();
      return;
    }

    _bestMatches.clear();

    for (var row in _gridTexts) {
      String bestMatch = "";
      double bestScore = 0.0;

      for (var course in courseData) {
        double score = 0.0;

        for (int i = 0; i < row.length; i++) {
          String text = row[i].replaceAll(RegExp(r'\s+'), '').toLowerCase();
          if (text.isNotEmpty) {
            double weight = 1.0;
            if (i == 0) {
              if (text == "未辨識到文字") {
                bestMatch = "";
                break;
              } else {
                weight = 3.0;
                score += weight *
                    _calculateSimilarity(
                        text,
                        course['Name']
                            .replaceAll(RegExp(r'\s+'), '')
                            .toLowerCase());
              }
            } else if (i == 1) {
              weight = 2.0;
              score += weight *
                  _calculateSimilarity(
                      text,
                      course['Id']
                          .replaceAll(RegExp(r'\s+'), '')
                          .toLowerCase());
            } else if (i == 2) {
              weight = 0.5;
              score += weight *
                  _calculateSimilarity(
                      text,
                      course['Department']
                          .replaceAll(RegExp(r'\s+'), '')
                          .toLowerCase());
            } else if (i == 3) {
              if (course['Location'].isNotEmpty) {
                weight = 5;
                score += weight *
                    _calculateSimilarity(
                        text,
                        course['Location'][0]
                            .replaceAll(RegExp(r'\s+'), '')
                            .toLowerCase());
              }
            }

            if (score > bestScore) {
              bestScore = score;
              bestMatch = course['Name'];
            }
          }
        }
      }

      if (bestScore > 0) {
        _bestMatches.add(bestMatch);
        debugPrint('最佳匹配課程: $bestMatch - 分數: $bestScore');
      } else {
        _bestMatches.add("");
        debugPrint('未找到匹配課程');
      }
    }
  }

  static void onCardTap(BuildContext context, String courseName,
      Function(String) onCourseChanged) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('選擇課程'),
          content: Text('目前選擇的課程是: $courseName\n\n是否要更改課程?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showCourseOptions(context, courseName, onCourseChanged);
              },
              child: const Text('更改課程'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  static void showCourseOptions(BuildContext context, String currentCourse,
      Function(String) onCourseChanged) {
    List<Map<String, dynamic>> similarCourses =
        findSimilarCourses(currentCourse);

    // 添加 "無課程" 選項
    similarCourses.insert(0, {'Name': ''});

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('選擇相似課程'),
          content: SizedBox(
            height: 300,
            width: 300,
            child: ListView.builder(
              itemCount: similarCourses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(similarCourses[index]['Name']),
                  onTap: () {
                    debugPrint('選擇的課程: ${similarCourses[index]['Name']}');
                    String selectedCourse = similarCourses[index]['Name'];
                    onCourseChanged(selectedCourse); // 更新選擇的課程名稱

                    // 如果選擇的是 "無課程"，將對應的最佳匹配設置為空字串
                    if (selectedCourse == '無課程') {
                      int currentIndex =
                          CourseDialogs.bestMatches.indexOf(currentCourse);
                      if (currentIndex != -1) {
                        CourseDialogs.bestMatches[currentIndex] = ""; // 設置為空白
                      }
                    }

                    Navigator.of(context).pop(); // 關閉對話框
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                showCustomCourseInput(
                    context, currentCourse, onCourseChanged); // 提供自定義輸入框
              },
              child: const Text('手動輸入課程'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  static void showCustomCourseInput(BuildContext context, String currentCourse,
      Function(String) onCourseChanged) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('手動輸入課程'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: '輸入課程名稱'),
            keyboardType: TextInputType.text, // 確保可以輸入中文
          ),
          actions: [
            TextButton(
              onPressed: () {
                String customCourseName = controller.text.trim();
                if (customCourseName.isNotEmpty) {
                  Navigator.of(context).pop(); // 先關閉當前對話框
                  showSimilarCourses(context, customCourseName, currentCourse,
                      onCourseChanged); // 然後顯示相似課程
                }
              },
              child: const Text('確認'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  static Future<void> showSimilarCourses(
      BuildContext context,
      String customCourseName,
      String currentCourse,
      Function(String) onCourseChanged) async {
    // 提取課程資料
    List<dynamic> results = courseData; // 使用全局課程資料
    List similarCourses = results
        .where((course) => course['Name'].contains(customCourseName))
        .toList();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('相似課程'),
          content: SizedBox(
            width: double.maxFinite, // 使對話框寬度自適應
            child: ListView.builder(
              itemCount: similarCourses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(similarCourses[index]['Name']),
                  onTap: () {
                    debugPrint('選擇的課程: ${similarCourses[index]['Name']}');
                    onCourseChanged(similarCourses[index]['Name']); // 更新選擇的課程名稱
                    Navigator.of(context).pop(); // 關閉對話框
                  },
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 關閉對話框
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  static List<Map<String, dynamic>> findSimilarCourses(String currentCourse) {
    List<Map<String, dynamic>> similarCourses = [];
    for (var course in courseData) {
      double score = _calculateSimilarity(currentCourse, course['Name']);
      if (score > 0.3) {
        // 設定一個閾值
        similarCourses.add(course);
      }
    }
    return similarCourses;
  }

  static double _calculateSimilarity(String a, String b) {
    return a.similarityTo(b); // 使用 string_similarity 包來計算相似度
  }
}
