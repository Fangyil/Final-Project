import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CourseService {
  // 儲存課程
  Future<void> saveCourses(List<String> courses) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('savedCourses', courses);
    debugPrint('課程已儲存');
  }

  // 載入儲存的課程
  Future<List<String>> loadSavedCourses() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('savedCourses') ?? [];
  }

  // 獲取課程數據
  Future<Map<String, dynamic>> getCourseData() async {
    final String jsonString =
        await rootBundle.loadString('assets/json_total.json');
    return json.decode(jsonString);
  }

  // 載入所有課程數據
  Future<List<Map<String, dynamic>>> loadCourseData() async {
    final String jsonString =
        await rootBundle.loadString('assets/json_total.json');
    final List<dynamic> jsonResponse = json.decode(jsonString);
    return jsonResponse.map((data) => data as Map<String, dynamic>).toList();
  }

  // 獲取課程位置
  Future<Map<String, String>> getCourseLocations() async {
    final courses = await loadCourseData();
    Map<String, String> courseLocations = {};

    for (var course in courses) {
      String name = course['Name'];
      String location = course['Location'];
      courseLocations[name] = location;
    }

    debugPrint(courseLocations as String?);
    return courseLocations;
  }

  // 儲存課程到指定資料夾
  Future<void> saveCoursesToFolder(
      List<String> courses, String folderName) async {
    final directory = await getApplicationDocumentsDirectory();
    final folder = Directory('${directory.path}/$folderName');

    if (!await folder.exists()) {
      await folder.create(recursive: true);
    }

    final file = File('${folder.path}/courses.txt');
    await file.writeAsString(courses.join('\n'));

    // 更新已儲存的資料夾列表
    final prefs = await SharedPreferences.getInstance();
    List<String> savedFolders = prefs.getStringList('savedFolders') ?? [];
    if (!savedFolders.contains(folderName)) {
      savedFolders.add(folderName);
      await prefs.setStringList('savedFolders', savedFolders);
    }

    debugPrint('課程已儲存到 $folderName');
  }

  // 載入儲存的課程
  Future<List<String>> loadCoursesFromFolder(String folderName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$folderName/courses.txt');

    if (await file.exists()) {
      return await file.readAsLines();
    } else {
      return [];
    }
  }

  // 獲取所有資料夾名稱
  Future<List<String>> getSavedFolders() async {
    final prefs = await SharedPreferences.getInstance();
    List<String> savedFolders = prefs.getStringList('savedFolders') ?? [];

    final directory = await getApplicationDocumentsDirectory();
    List<String> existingFolders = [];

    for (String folderName in savedFolders) {
      final folderPath = '${directory.path}/$folderName';
      final folder = Directory(folderPath);

      // 檢查資料夾是否存在
      if (await folder.exists()) {
        existingFolders.add(folderName);
      }
    }

    // 如果 existingFolders 與 savedFolders 不一致，更新 SharedPreferences
    if (existingFolders.length != savedFolders.length) {
      await prefs.setStringList('savedFolders', existingFolders);
    }

    return existingFolders;
  }

  Future<void> deleteFolder(String folderName) async {
    // 假設您有一個資料夾的儲存結構，可以根據 folderName 刪除資料夾
    // 這裡的邏輯取決於您儲存資料夾的方式，例如從本地檔案系統或資料庫中刪除

    // 範例：從本地檔案系統刪除資料夾
    final directory = await getApplicationDocumentsDirectory();
    final folderPath = '${directory.path}/$folderName';

    final folder = Directory(folderPath);
    if (await folder.exists()) {
      await folder.delete(recursive: true); // 遞迴刪除資料夾及其內容
      debugPrint('資料夾 $folderName 已被刪除');
    } else {
      debugPrint('資料夾 $folderName 不存在');
    }
  }
}
