// import 'package:flutter/material.dart';
// import 'package:project/course/service.dart';

// class FolderService {
//   final CourseService _courseService;

//   FolderService(this._courseService);

//   Future<String?> selectFolder(BuildContext context) async {
//     List<String> folderNames = await _courseService.getSavedFolders();
//     return await showDialog<String>(
//       context: context,
//       builder: (context) {
//         return AlertDialog(
//           title: const Text('選擇資料夾'),
//           content: SizedBox(
//             width: 300,
//             height: 400,
//             child: ListView.builder(
//               itemCount: folderNames.length,
//               itemBuilder: (context, index) {
//                 return ListTile(
//                   title: Text(folderNames[index]),
//                   onTap: () {
//                     Navigator.of(context).pop(folderNames[index]);
//                   },
//                 );
//               },
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // 取消
//               },
//               child: const Text('取消'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void showDeleteFolderDialog(BuildContext context) async {
//     List<String> folderNames = await _courseService.getSavedFolders();
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
//                     selectedFolderToDelete = folderNames[index];
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
//                   await _courseService.deleteFolder(selectedFolderToDelete!);
//                   Navigator.of(context).pop();
//                 }
//               },
//               child: const Text('刪除'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop(); // 取消
//               },
//               child: const Text('取消'),
//             ),
//           ],
//         );
//       },
//     );
//   }
  
// }
