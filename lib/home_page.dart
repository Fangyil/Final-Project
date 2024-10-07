import 'package:flutter/material.dart';
import 'package:project/chatbot/page.dart'; // 引入 ChatPage
import 'package:project/image/page.dart';
// import 'package:project/image/image_picker.dart';
import 'map/page.dart';
// import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // 當前選擇的索引

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index; // 更新選擇的索引
    });
  }

  Widget _buildBody() {
    switch (_selectedIndex) {
      case 0:
        return const ImagePage(); // 傳遞選擇圖片的回調
      case 1:
        return const ChatPage(); // 查詢機器人畫面
      case 2:
        return const MapPage(); // 地圖畫面
      default:
        return Container(); // 預設情況下返回空容器
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(), // 根據選擇的索引顯示不同的頁面
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: '可點擊課表',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat),
            label: '查詢機器人',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: '地圖查詢',
          ),
        ],
        currentIndex: _selectedIndex, // 當前選擇的索引
        onTap: _onItemTapped, // 點擊事件
      ),
    );
  }
}
