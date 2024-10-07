import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ColorPickerHelper {
  Color nonEditingColor = Colors.grey;  // 非編輯模式的預設顏色
  Color editingColor = Colors.grey;     // 編輯模式的預設顏色

  Future<void> loadColors() async {
    final prefs = await SharedPreferences.getInstance();
    String? nonEditingColorString = prefs.getString('nonEditingColor');
    String? editingColorString = prefs.getString('editingColor');

    if (nonEditingColorString != null) {
      nonEditingColor = Color(int.parse(nonEditingColorString));
    }
    if (editingColorString != null) {
      editingColor = Color(int.parse(editingColorString));
    }
  }

  Future<void> saveColors() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('nonEditingColor', nonEditingColor.value.toString());
    await prefs.setString('editingColor', editingColor.value.toString());
  }

  void pickColor(BuildContext context, bool isEditing, Function update) async {
    Color? pickedColor = await showDialog<Color>(
      context: context,
      builder: (context) {
        Color tempColor = isEditing ? editingColor : nonEditingColor;
        return AlertDialog(
          title: const Text('選擇顏色'),
          content: SingleChildScrollView(
            child: BlockPicker(
              pickerColor: tempColor,
              onColorChanged: (color) {
                Navigator.of(context).pop(color);
              },
            ),
          ),
        );
      },
    );

    if (pickedColor != null) {
      if (isEditing) {
        editingColor = pickedColor;
      } else {
        nonEditingColor = pickedColor;
      }
      await saveColors(); // 儲存顏色設定
      update(); // 更新界面
    }
  }

  void showColorSelectionDialog(BuildContext context, Function update) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('選擇顏色'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();       // 關閉對話框
                  pickColor(context, false, update); // 設定非編輯模式顏色 
                },
                child: const Text('選擇非編輯模式顏色'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();       // 關閉對話框
                  pickColor(context, true, update);  // 設定編輯模式顏色
                },
                child: const Text('選擇編輯模式顏色'),
              ),
            ],
          ),
        );
      },
    );
  }
}
