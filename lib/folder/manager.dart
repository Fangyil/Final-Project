// import 'service.dart';
// import 'package:flutter/material.dart';
// import 'package:project/course/service.dart';

// class FolderManager {
//   final FolderService _folderService;
//   final CourseService _courseService;

//   FolderManager(this._folderService, this._courseService);

//   Future<void> saveCourses(BuildContext context) async {
//     String? selectedFolder = await _folderService.selectFolder(context);
//     if (selectedFolder != null) {
//       await _courseService.saveCoursesToFolder(['Course1', 'Course2'], selectedFolder);
//     }
//   }

//   Future<void> loadCourses(BuildContext context, String folderName) async {
//     List<String> courses = await _courseService.loadCoursesFromFolder(folderName);
//     // 使用 courses 的邏輯
//   }

//   void showDeleteFolderDialog(BuildContext context) {
//     _folderService.showDeleteFolderDialog(context);
//   }
// }
