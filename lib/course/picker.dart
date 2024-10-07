// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'dialogs.dart';

// class CoursePickerHelper{

//     Future<void> _loadSavedCourses() async {
//     final savedCourses = await _courseService.loadSavedCourses();
//     setState(() {
//       _bestMatches.clear();
//       _bestMatches.addAll(savedCourses);
//       isLoading = _bestMatches.isEmpty;
//     });

//     final prefs = await SharedPreferences.getInstance();
//     imagePath = prefs.getString('savedImagePath');

//     if (imagePath != null) {
//       final file = File(imagePath!);
//       if (await file.exists()) {
//         currentImagePath = imagePath;
//         await loadImage();
//       } else {
//         debugPrint('圖片路徑不存在: $imagePath');
//       }
//     }

//     if (_bestMatches.isNotEmpty) {
//       setState(() {
//         isLoading = false;
//       });
//     } else {
//       await _matchCourses();
//     }
//   }

//   Future<void> _matchCourses() async {
//     if (cutImages.isNotEmpty && !hasMatchedCourses) {
//       // 檢查是否已經比對過
//       await _performOCR();
//       hasMatchedCourses = true; // 設置標誌為已比對
//     } else {
//       debugPrint('切割圖片列表為空，跳過 OCR 辨識');
//     }
//   }

//   Future<void> _saveCourses() async {
//     await _courseService.saveCourses(_bestMatches);
//     if (imagePath != null) {
//       final prefs = await SharedPreferences.getInstance();
//       await prefs.setString('savedImagePath', imagePath!);
//     }
//   }

//   Future<void> _loadJsonData() async {
//     if (_courseData.isEmpty) {
//       final rawData = await _courseService.getCourseData();
//       if (rawData['results'] is List) {
//         _courseData = {
//           'results': List<Map<String, dynamic>>.from(rawData['results']),
//         };
//         CourseDialogs.setCourseData(_courseData['results']);
//       } else {
//         debugPrint('Unexpected data format: ${rawData['results']}');
//       }
//     }
//   }
// }