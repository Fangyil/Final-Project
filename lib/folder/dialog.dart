// import 'package:flutter/material.dart';
// import 'package:project/folder/service.dart';

// class FolderDialog {
//   Future<String?> _selectFolder() async {
//     List<String> folderNames = await _courseService.getSavedFolders();
//     String? selectedFolder;
//     if (mounted) {
//       // 顯示資料夾列表的對話框
//       selectedFolder = await showDialog<String>(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: const Text('選擇資料夾'),
//             content: SizedBox(
//               width: 300,
//               height: 400,
//               child: ListView.builder(
//                 itemCount: folderNames.length,
//                 itemBuilder: (context, index) {
//                   return ListTile(
//                     title: Text(folderNames[index]),
//                     onTap: () {
//                       Navigator.of(context).pop(folderNames[index]); // 返回選擇的資料夾
//                     },
//                   );
//                 },
//               ),
//             ),
//             actions: [
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   IconButton(
//                     icon: const Icon(Icons.delete, color: Colors.red), // 使用刪除圖示
//                     onPressed: () {
//                       Navigator.of(context).pop(); // 關閉對話框
//                       _showDeleteFolderDialog(folderNames); // 顯示刪除資料夾對話框
//                     },
//                   ),
//                   TextButton(
//                     onPressed: () {
//                       Navigator.of(context).pop(); // 取消選擇
//                     },
//                     child: const Text('取消'),
//                   ),
//                 ],
//               ),
//             ],
//           );
//         },
//       );
//     }

//     return selectedFolder; // 返回選擇的資料夾名稱
//   }

//   void _showDeleteFolderDialog(List<String> folderNames) {
//     showDialog(
//       context: context,
//       builder: (context) {
//         String? selectedFolderToDelete;

//         return AlertDialog(
//           title: const Text('刪除資料夾'),
//           content: SizedBox(
//             width: 300,
//             height: 400,
//             child: ListView.builder(
//               itemCount: folderNames.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(folderNames[index]),
//                   onTap: () {
//                     setState(() {
//                       selectedFolderToDelete = folderNames[index];
//                     });
//                   },
//                   selected: selectedFolderToDelete == folderNames[index],
//                 );
//               },
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () async {
//                 if (selectedFolderToDelete != null) {
//                   await _deleteFolder(selectedFolderToDelete!); // 刪除資料夾
//                   setState(() {
//                     folderNames.remove(selectedFolderToDelete); // 移除資料夾
//                   });
//                   if (context.mounted) {
//                     Navigator.of(context).pop(); // 關閉對話框
//                   }
//                   if (context.mounted) {
//                     Navigator.of(context).pop(); // 返回到資料夾選擇頁面
//                   }
//                 }
//               },
//               child: const Text('刪除'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // 取消刪除
//               },
//               child: const Text('取消'),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
