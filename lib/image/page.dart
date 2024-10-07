import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:project/image/ocr_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:project/map/location.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../tools/custom_card.dart';
import 'grid_detection.dart';
import 'utils.dart';
import 'package:image/image.dart' as img;
import '../course/dialogs.dart';
import '../course/service.dart';
import 'color_picker.dart';
// import 'package:project/course/course_picker.dart';
import '../tools/tooltip.dart';
import 'package:project/course/param.dart';

class ImageMatchResult {
  final String imagePath;
  final List<String> matches;

  ImageMatchResult(this.imagePath, this.matches);
}

class ImagePage extends StatefulWidget {
  const ImagePage({super.key});

  @override
  State<ImagePage> createState() => _ImagePageState();
}

class _ImagePageState extends State<ImagePage> {
  List<List<String>> _gridTexts = [];
  final List<String> _bestMatches = [];
  Map<String, dynamic> _courseData = {};
  String? imagePath;
  String? currentImagePath;
  List<ui.Image> cutImages = [];
  ui.Image? uiImage;
  List<Rect> gridCells = [];
  bool isLoading = true;
  bool isImageCut = false;
  bool isGridDetected = false;
  bool isEditing = false;
  bool showSavedSnackBar = false;
  bool hasMatchedCourses = false;
  bool hasClickedHelpTool = false;

  final OcrService _ocrService = OcrService();
  final GridDetection _gridDetection = GridDetection();
  final CourseService _courseService = CourseService();
  final ImagePicker _picker = ImagePicker();

  List<ImageMatchResult> imageMatchResults = [];

  late ColorPickerHelper colorPickerHelper;
  late CourseParam courseParam;
  // late ImagePickerHelper imagePickerHelper;

  @override
  void initState() {
    super.initState();

    colorPickerHelper = ColorPickerHelper(); // 初始化 ColorPicker 類
    colorPickerHelper.loadColors().then((_) {
      setState(() {}); // 更新狀態
    });

    courseParam = CourseParam();

    // imagePickerHelper = ImagePickerHelper(_matchCourses);
    // setState(() {
    //   // 在這裡更新狀態
    // });
    _loadJsonData();
    _loadSavedCourses();
  }

  Future<void> _loadSavedCourses() async {
    final savedCourses = await _courseService.loadSavedCourses();
    setState(() {
      _bestMatches.clear();
      _bestMatches.addAll(savedCourses);
      isLoading = _bestMatches.isEmpty;
    });

    final prefs = await SharedPreferences.getInstance();
    imagePath = prefs.getString('savedImagePath');

    if (imagePath != null) {
      final file = File(imagePath!);
      if (await file.exists()) {
        currentImagePath = imagePath;
        await loadImage();
      } else {
        debugPrint('圖片路徑不存在: $imagePath');
      }
    }

    if (_bestMatches.isNotEmpty) {
      setState(() {
        isLoading = false;
      });
    } else {
      await _matchCourses();
    }
  }

  Future<void> _matchCourses() async {
    if (cutImages.isNotEmpty && !hasMatchedCourses) {
      // 檢查是否已經比對過
      await _performOCR();
      hasMatchedCourses = true; // 設置標誌為已比對
    } else {
      debugPrint('切割圖片列表為空，跳過 OCR 辨識');
    }
  }

  Future<void> _saveCourses() async {
    await _courseService.saveCourses(_bestMatches);
    if (imagePath != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('savedImagePath', imagePath!);
    }
  }

  Future<void> _loadJsonData() async {
    if (_courseData.isEmpty) {
      final rawData = await _courseService.getCourseData();
      if (rawData['results'] is List) {
        _courseData = {
          'results': List<Map<String, dynamic>>.from(rawData['results']),
        };
        CourseDialogs.setCourseData(_courseData['results']);
      } else {
        debugPrint('Unexpected data format: ${rawData['results']}');
      }
    }
  }

////
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      currentImagePath = pickedFile.path;
      imagePath = pickedFile.path;

      isGridDetected = false;
      isImageCut = false;
      cutImages.clear();
      _bestMatches.clear();
      hasMatchedCourses = false; // 重置標誌

      await loadImage();

      if (uiImage != null) {
        await detectGrid();
        cutImages = await cutImage(uiImage!, gridCells);

        if (cutImages.isNotEmpty) {
          await _matchCourses(); // 這裡會自動比對課程
        } else {
          debugPrint('切割圖片列表為空');
        }
      }
    }
  }

  Future<void> loadImage() async {
    try {
      final Uint8List bytes = await File(imagePath!).readAsBytes();
      final ui.Codec codec = await ui.instantiateImageCodec(bytes);
      final ui.FrameInfo fi = await codec.getNextFrame();
      setState(() {
        uiImage = fi.image;
        isLoading = true;
      });
      debugPrint(
          'Image loaded successfully: ${uiImage!.width}x${uiImage!.height}');

      if (!isGridDetected) {
        await detectGrid();
        cutImages = await cutImage(uiImage!, gridCells);
        if (cutImages.isEmpty) {
          debugPrint('切割的圖片列表為空');
          return;
        }
        isGridDetected = true;
      }

      if (_bestMatches.isEmpty && !isImageCut) {
        await _performOCR();
        isImageCut = true;
      }
    } catch (e) {
      debugPrint('Error loading image: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> detectGrid() async {
    if (uiImage == null) {
      debugPrint('Image not loaded');
      return;
    }

    final ByteData? byteData =
        await uiImage!.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      debugPrint('Unable to read image');
      return;
    }
    final Uint8List uint8List = byteData.buffer.asUint8List();
    final img.Image? image = img.decodeImage(uint8List);

    if (image == null) {
      debugPrint('Unable to decode image');
      return;
    }

    List<Rect> newGridCells = await _gridDetection.detectGrid(image);
    debugPrint('Detected grid cells: ${newGridCells.length}');
    setState(() {
      gridCells = newGridCells;
    });
  }

  Future<void> _performOCR() async {
    if (cutImages.isNotEmpty) {
      List<String> recognizedTexts = [];

      for (var i = 0; i < cutImages.length; i++) {
        if (i % 8 == 0) {
          recognizedTexts.add("時間");
          continue;
        }

        ui.Image resizedImage = await resizeImage(cutImages[i], 2.0);
        String filePath =
            '${(await getTemporaryDirectory()).path}/cut_image_$i.png';
        await saveImageToFile(resizedImage, filePath);

        String recognizedText = '';
        try {
          recognizedText = await _ocrService.performOCR(filePath);
        } catch (e) {
          debugPrint('OCR error: $e');
        }

        if (recognizedText.isNotEmpty) {
          recognizedTexts.add(recognizedText);
        } else {
          recognizedTexts.add("未辨識到文字");
        }
      }

      // 儲存匹配結果
      imageMatchResults
          .add(ImageMatchResult(currentImagePath ?? '', recognizedTexts));

      setState(() {
        _gridTexts = recognizedTexts.map((text) => [text]).toList();
        CourseDialogs.matchCourses(_gridTexts);
        _bestMatches.clear(); // 清空最佳匹配
        _bestMatches.addAll(CourseDialogs.bestMatches); // 添加新匹配
        _saveCourses(); // 儲存課程
        isLoading = false; // 停止加載
      });
    } else {
      debugPrint('切割圖片列表為空，跳過 OCR 辨識');
    }
  }

////
  void _onCardTap(int index, bool isEditing) {
    if (index < _bestMatches.length) {
      String courseName = _bestMatches[index];

      if (isEditing) {
        CourseDialogs.onCardTap(context, courseName, (newCourseName) {
          setState(() {
            _bestMatches[index] = newCourseName;
          });
        });
      } else {
        String? location = _getLocationFromJson(courseName);

        if (location != null) {
          int locationIndex = Location.locationNames
              .indexWhere((name) => name.contains(location));

          if (locationIndex != -1) {
            String url =
                'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(Location.latLng[locationIndex])}';
            debugPrint('Opening URL: $url');
            _openMap(url);
          } else {
            _showSnackBar('找不到該課程的位置訊息');
          }
        } else {
          _showSnackBar('找不到該課程的位置訊息');
        }
      }
    } else {
      _showSnackBar('找不到該課程的位置訊息');
    }
  }

  void _openMap(String destination) async {
    final Uri launchUri = Uri(
      scheme: 'https',
      host: 'www.google.com',
      path: '/maps/dir/',
      queryParameters: {
        'api': '1',
        'destination': destination,
      },
    );

    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      _showSnackBar('無法打開地圖應用');
      debugPrint('Could not launch $launchUri');
    }
  }

  String? _getLocationFromJson(String courseName) {
    for (var course in _courseData['results']) {
      if (course['Name'] == courseName) {
        String location = course['Location'] is List
            ? course['Location'][0]
            : course['Location'];
        return location.substring(0, 3);
      }
    }
    debugPrint('找不到位置');
    return null;
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // 顯示課程詳細資訊
  void _showCourseDetails(String courseName) {
    for (var course in _courseData['results']) {
      if (course['Name'] == courseName) {
        String details = courseParam.getCourseDetails(course);
        String? location = _getLocationFromJson(courseName);

        if (location != null) {
          int locationIndex = Location.locationNames
              .indexWhere((name) => name.contains(location));

          String? coordinates;
          if (locationIndex != -1) {
            coordinates = Location.latLng[locationIndex];
          }

          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text(course['Name']),
                content: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(details),
                      const SizedBox(height: 16),
                      if (coordinates != null) ...[
                        TextButton(
                          child: const Text('查看地圖'),
                          onPressed: () {
                            String url =
                                'https://www.google.com/maps/dir/?api=1&destination=${Uri.encodeComponent(coordinates!)}';
                            debugPrint('Opening URL: $url');
                            launchUrl(Uri.parse(url));
                            Navigator.of(context).pop();
                          },
                        ),
                      ] else ...[
                        const Text('找不到該課程的位置訊息'),
                      ],
                    ],
                  ),
                ),
                actions: <Widget>[
                  TextButton(
                    child: const Text('關閉'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          break;
        }
      }
    }
  }

  Future<String?> _selectFolder() async {
    List<String> folderNames = await _courseService.getSavedFolders();
    String? selectedFolder;
    if (mounted) {
      // 顯示資料夾列表的對話框
      selectedFolder = await showDialog<String>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('選擇資料夾'),
            content: SizedBox(
              width: 300,
              height: 400,
              child: ListView.builder(
                itemCount: folderNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(folderNames[index]),
                    onTap: () {
                      Navigator.of(context).pop(folderNames[index]); // 返回選擇的資料夾
                    },
                  );
                },
              ),
            ),
            actions: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // IconButton(
                  //   icon: const Icon(Icons.delete, color: Colors.red), // 使用刪除圖示
                  //   onPressed: () {
                  //     Navigator.of(context).pop(); // 關閉對話框
                  //     _showDeleteFolderDialog(folderNames); // 顯示刪除資料夾對話框
                  //   },
                  // ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // 取消選擇
                    },
                    child: const Text('取消'),
                  ),
                ],
              ),
            ],
          );
        },
      );
    }

    return selectedFolder; // 返回選擇的資料夾名稱
  }

  void _showDeleteFolderDialog(List<String> folderNames) {
    showDialog(
      context: context,
      builder: (context) {
        String? selectedFolderToDelete;

        return AlertDialog(
          title: const Text('刪除資料夾'),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView.builder(
              itemCount: folderNames.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(folderNames[index]),
                  onTap: () {
                    setState(() {
                      selectedFolderToDelete = folderNames[index];
                    });
                  },
                  selected: selectedFolderToDelete == folderNames[index],
                );
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () async {
                if (selectedFolderToDelete != null) {
                  await _deleteFolder(selectedFolderToDelete!); // 刪除資料夾
                  setState(() {
                    folderNames.remove(selectedFolderToDelete); // 移除資料夾
                  });
                  if (context.mounted) {
                    Navigator.of(context).pop(); // 關閉對話框
                  }
                  if (context.mounted) {
                    Navigator.of(context).pop(); // 返回到資料夾選擇頁面
                  }
                }
              },
              child: const Text('刪除'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 取消刪除
              },
              child: const Text('取消'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteFolder(String folderName) async {
    await _courseService.deleteFolder(folderName); // 調用 deleteFolder 方法
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("已刪除資料夾 $folderName"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 儲存課程到資料夾的對話框
  void _showSaveDialog() async {
    final TextEditingController folderNameController = TextEditingController();
    String? selectedFolder;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('儲存課程'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: folderNameController,
                decoration: const InputDecoration(hintText: '請輸入資料夾名稱'),
              ),
              const SizedBox(height: 10),
              // 如果選擇的資料夾為 null，則不顯示該行
              if (selectedFolder != null && selectedFolder!.isNotEmpty)
                Text(selectedFolder!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                // 選擇資料夾的邏輯
                selectedFolder = await _selectFolder();
                if (selectedFolder != null) {
                  folderNameController.text = selectedFolder!;
                }
              },
              child: const Text('選擇資料夾'),
            ),
            TextButton(
              onPressed: () async {
                String folderName = folderNameController.text.trim();
                if (folderName.isNotEmpty) {
                  await _saveCoursesToFolder(folderName);
                  if (!context.mounted) return;
                  Navigator.of(context).pop();
                }
              },
              child: const Text('儲存'),
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

  // 儲存課程到指定資料夾
  Future<void> _saveCoursesToFolder(String folderName) async {
    await _courseService.saveCoursesToFolder(_bestMatches, folderName);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("已儲存所有課程到 $folderName"),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  }

  // 載入資料夾中的課程
  Future<void> _loadCoursesFromFolder(String folderName) async {
    List<String> courses =
        await _courseService.loadCoursesFromFolder(folderName);
    setState(() {
      _bestMatches.clear();
      _bestMatches.addAll(courses);
    });
  }

  // 顯示資料夾列表的對話框
  void _showFolderListDialog() async {
    List<String> folderNames = await _courseService.getSavedFolders();
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('選擇資料夾'),
            content: SizedBox(
              width: 300,
              height: 400,
              child: ListView.builder(
                itemCount: folderNames.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(folderNames[index]),
                    onTap: () async {
                      await _loadCoursesFromFolder(folderNames[index]);
                      if (!context.mounted) return;
                      Navigator.of(context).pop();
                    },
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  _showDeleteFolderDialog(folderNames); // 顯示刪除資料夾對話框
                },
                child: const Text('刪除資料夾'),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: isEditing
            ? colorPickerHelper.editingColor
            : colorPickerHelper.nonEditingColor,
        leading: TooltipButton(
          '操作說明',
          Icons.info,
          () {
            showHelpTooltip(context, () {
              setState(() {
                hasClickedHelpTool = !hasClickedHelpTool; // 切換狀態
                hasClickedHelpTool = false; // 關閉時重置狀態
              });
            });
          },
        ),
        actions: [
          TooltipButton(
            '上傳圖片',
            Icons.photo,
            () async {
              await _pickImage();
              setState(() {});
            },
          ),
          TooltipButton('選擇顏色', Icons.color_lens, () {
            colorPickerHelper.showColorSelectionDialog(context, () {
              setState(() {});
            });
          }),
          TooltipButton(
              isEditing ? '完成編輯' : '編輯模式', isEditing ? Icons.check : Icons.edit,
              () {
            setState(() {
              isEditing = !isEditing;
            });
          }),
          TooltipButton('儲存課程', Icons.save, _showSaveDialog),
          TooltipButton('顯示資料夾', Icons.folder, _showFolderListDialog),
        ],
      ),
      body: Container(
        color: isEditing
            ? colorPickerHelper.editingColor.withOpacity(0.5)
            : colorPickerHelper.nonEditingColor
                .withOpacity(0.5), // 根據編輯模式改變背景顏色
        child: isLoading
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text("正在比對課程"),
                  ],
                ),
              )
            : Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Container(
                        padding: const EdgeInsets.all(5.0),
                        child: SizedBox(
                          width: MediaQuery.of(context).size.width * 1.5,
                          child: GridView.builder(
                            physics: const BouncingScrollPhysics(),
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 8,
                              childAspectRatio: 1.0,
                            ),
                            itemCount: 120, // 固定為 120 個卡片
                            shrinkWrap: true,
                            itemBuilder: (context, index) {
                              if (_bestMatches.isEmpty) {
                                return const CustomCard(text: '');
                              }
                              if (index == 0) {
                                return Container();
                              } else if (index > 0 && index < 8) {
                                return Container(
                                  margin: const EdgeInsets.all(1.0),
                                  child: Center(
                                    child: Text(
                                      courseParam.weeks[index - 1],
                                      style: const TextStyle(fontSize: 16.0),
                                    ),
                                  ),
                                );
                              } else if (index % 8 == 0) {
                                return Center(
                                  child: Text(
                                    courseParam
                                        .timeSlots[index ~/ 8], // 根據索引顯示時間段
                                    style: const TextStyle(fontSize: 14.0),
                                  ),
                                );
                              } else {
                                int cardIndex = index - 8;

                                if (cardIndex < _bestMatches.length &&
                                    cardIndex < cutImages.length) {
                                  // if (cardIndex < cutImages.length) {
                                  return Container(
                                    margin: const EdgeInsets.all(1.0),
                                    child: cardIndex % 8 == 0
                                        ? Center(
                                            child: Text(
                                              courseParam.timeSlots[
                                                  cardIndex ~/ 8], // 根據索引顯示時間段
                                              style: const TextStyle(
                                                  fontSize: 14.0),
                                            ),
                                          )
                                        : GestureDetector(
                                            onTap: () => _onCardTap(
                                                cardIndex, isEditing),
                                            onLongPress: () {
                                              _showCourseDetails(
                                                  _bestMatches[cardIndex]);
                                            },
                                            child: CustomCard(
                                                text: _bestMatches[cardIndex])),
                                  );
                                  // }
                                } else {
                                  return GestureDetector(
                                    onTap: () => _onCardTap(index, isEditing),
                                    onLongPress: () {
                                      _showCourseDetails(
                                          _bestMatches[cardIndex]);
                                    },
                                    child: const CustomCard(text: ''),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
