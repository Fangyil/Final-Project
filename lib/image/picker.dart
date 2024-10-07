// import 'dart:io';
// import 'dart:typed_data';
// import 'dart:ui' as ui;
// import 'package:image_picker/image_picker.dart';
// import 'package:image/image.dart' as img;
// import 'package:flutter/material.dart';
// import 'package:path_provider/path_provider.dart';
// import '../course/dialogs.dart';
// import 'grid_detection.dart';
// import 'utils.dart';
// import 'ocr_service.dart';
// import 'image_page.dart';

// class ImageMatchResult {
//   final String imagePath;
//   final List<String> matches;

//   ImageMatchResult(this.imagePath, this.matches);
// }

// class ImagePickerHelper extends InheritedWidget {
//   final _ImagePageState model;
//   final ImagePicker _picker = ImagePicker();
//   final Function() onMatchCourses;
//   final Function() onSaveCourses;

//   ImagePickerHelper(this.onMatchCourses, this.onSaveCourses);

//   Future<void> pickImage(
//     String? currentImagePath,
//     String? imagePath,
//     bool gridDetected,
//     bool imageCut,
//     List<ui.Image> cutImages,
//     List<String> bestMatches,
//     bool hasMatchedCourses,
//     ui.Image? uiImage,
//     List<Rect> gridCells,
//     bool loading,
//     List<List<String>> gridTexts,
//     List<ImageMatchResult> imageMatchResults,
//   ) async {
//     final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
//     if (pickedFile != null) {
//       // 更新路徑
//       currentImagePath = pickedFile.path;
//       imagePath = pickedFile.path;

//       // 重置狀態
//       gridDetected = false;
//       imageCut = false;
//       cutImages.clear();
//       bestMatches.clear();
//       hasMatchedCourses = false; // 重置標誌

//       debugPrint('$currentImagePath\n$imagePath');
//       // 載入和處理圖片
//       await loadImage(
//         imagePath,
//         uiImage,
//         loading,
//         gridDetected,
//         gridCells,
//         cutImages,
//         imageCut,
//         bestMatches,
//         currentImagePath,
//         hasMatchedCourses,
//         gridTexts,
//         imageMatchResults,
//       );

//       if (uiImage != null) {
//         await detectGrid(uiImage, gridCells);
//         cutImages = await cutImage(uiImage, gridCells);

//         // // 更新參數
//         // onCutImagesChanged(cutImages);

//         if (cutImages.isNotEmpty) {
//           await onMatchCourses(); // 這裡會自動比對課程
//         } else {
//           debugPrint('切割圖片列表為空');
//         }
//       }
//     }
//   }

//   Future<void> loadImage(
//     String? imagePath,
//     ui.Image? uiImage,
//     bool loading,
//     bool gridDetected,
//     List<Rect> gridCells,
//     List<ui.Image> cutImages,
//     bool imageCut,
//     List<String> bestMatches,
//     String? currentImagePath,
//     bool hasMatchedCourses,
//     List<List<String>> gridTexts,
//     List<ImageMatchResult> imageMatchResults,
//   ) async {
//     try {
//       final Uint8List bytes = await File(imagePath!).readAsBytes();
//       final ui.Codec codec = await ui.instantiateImageCodec(bytes);
//       final ui.FrameInfo fi = await codec.getNextFrame();
//       // setState(() {
//       uiImage = fi.image;
//       loading = true;
//       // });
//       debugPrint(
//           'Image loaded successfully: ${uiImage.width}x${uiImage.height}');

//       if (!gridDetected) {
//         await detectGrid(uiImage, gridCells);
//         cutImages = await cutImage(uiImage, gridCells);
//         if (cutImages.isEmpty) {
//           debugPrint('切割的圖片列表為空');
//           return;
//         }
//         gridDetected = true;
//       }

//       if (bestMatches.isEmpty && !imageCut) {
//         await performOCR(
//           currentImagePath,
//           imagePath,
//           gridDetected,
//           imageCut,
//           cutImages,
//           bestMatches,
//           hasMatchedCourses,
//           uiImage,
//           gridCells,
//           gridTexts,
//           loading,
//           imageMatchResults,
//         );
//         imageCut = true;
//       }
//     } catch (e) {
//       debugPrint('Error loading image: $e');
//       // setState(() {
//       loading = false;
//       // });
//     }
//   }

//   Future<void> detectGrid(ui.Image? uiImage, List<Rect> gridCells) async {
//     if (uiImage == null) {
//       debugPrint('Image not loaded');
//       return;
//     }

//     final ByteData? byteData =
//         await uiImage.toByteData(format: ui.ImageByteFormat.png);
//     if (byteData == null) {
//       debugPrint('Unable to read image');
//       return;
//     }
//     final Uint8List uint8List = byteData.buffer.asUint8List();
//     final img.Image? image = img.decodeImage(uint8List);

//     if (image == null) {
//       debugPrint('Unable to decode image');
//       return;
//     }

//     List<Rect> newGridCells = await GridDetection().detectGrid(image);
//     debugPrint('Detected grid cells: ${newGridCells.length}');
//     // setState(() {
//     gridCells = newGridCells;
//     // });
//   }

//   Future<void> performOCR(
//     String? currentImagePath,
//     String? imagePath,
//     bool gridDetected,
//     bool imageCut,
//     List<ui.Image> cutImages,
//     List<String> bestMatches,
//     bool hasMatchedCourses,
//     ui.Image? uiImage,
//     List<Rect> gridCells,
//     List<List<String>> gridTexts,
//     bool loading,
//     List<ImageMatchResult> imageMatchResults,
//   ) async {
//     if (cutImages.isNotEmpty) {
//       List<String> recognizedTexts = [];

//       for (var i = 0; i < cutImages.length; i++) {
//         if (i % 8 == 0) {
//           recognizedTexts.add("時間");
//           continue;
//         }

//         ui.Image resizedImage = await resizeImage(cutImages[i], 2.0);
//         String filePath =
//             '${(await getTemporaryDirectory()).path}/cut_image_$i.png';
//         await saveImageToFile(resizedImage, filePath);

//         String recognizedText = '';
//         try {
//           recognizedText = await OcrService().performOCR(filePath);
//         } catch (e) {
//           debugPrint('OCR error: $e');
//         }

//         if (recognizedText.isNotEmpty) {
//           recognizedTexts.add(recognizedText);
//         } else {
//           recognizedTexts.add("未辨識到文字");
//         }
//       }

//       // 儲存匹配結果
//       imageMatchResults
//           .add(ImageMatchResult(currentImagePath ?? '', recognizedTexts));

//       // setState(() {
//       gridTexts = recognizedTexts.map((text) => [text]).toList();
//       CourseDialogs.matchCourses(gridTexts);
//       bestMatches.clear(); // 清空最佳匹配
//       bestMatches.addAll(CourseDialogs.bestMatches); // 添加新匹配
//       onSaveCourses(); // 儲存課程
//       loading = false; // 停止加載
//       // });
//     } else {
//       debugPrint('切割圖片列表為空，跳過 OCR 辨識');
//     }
//   }
// }
