import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  final ScrollController _scrollController =
      ScrollController(); // 新增 ScrollController

  @override
  void initState() {
    super.initState();
    // 加入歡迎訊息
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _messages.add({
          'message': '您好，請問今天有什麼需要協助的地方呢？ \n'
              '關於海洋大學系所位置與行政事務的問題 \n'
              '歡迎隨時向我詢問我喔 \n'
              '以下是一些常見的問題範例： \n'
              '\n '
              'Q：資工系在哪裡 \n'
              'A：你可以去電機2館3樓312室的資訊工程學系系辦 \n'
              '\n'
              'Q：我很傷心怎麼辦 \n'
              'A：你可以去海事大樓3樓318室的學務處諮商輔導 \n'
              '\n'
              '回復要5秒鐘 請稍等 \n'
              'Hello, may I need help today? \n'
              'Regarding the location and administrative affairs of Ocean University departments \n '
              'Feel free to ask me anytime \n'
              'Here are some examples of common questions: \n'
              '\n'
              'Q: Where is the Department of Information Engineering? \n'
              "You can go to Room 312, 3rd floor, Motor Building 2. You'll find a Department of Information Engineering there.\n"
              "\n"
              "Q: What should I do if I’m sad? \n"
              "You can go to Room 318, 3rd floor, Maritime Building You'll find a Counseling and Counseling Group of the Academic Affairs Office there.\n"
              "Reply takes 5 seconds. Please wait.",
          'time': DateTime.now().toLocal().toString(),
          'sender': 'bot',
        });
      });
      _scrollToBottom(); // 新增自動滾動至底部
    });
  }

  Future<void> sendMessage(String message) async {
    setState(() {
      _messages.add({
        'message': message,
        'time': DateTime.now().toLocal().toString(),
        'sender': 'user',
      });
    });
    _scrollToBottom(); // 發送訊息後自動滾動至底部

    try {
      final response = await http.post(
        Uri.parse('https://test20240829-2dc4d98e3968.herokuapp.com/chat'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"message": message}),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        setState(() {
          _messages.add({
            'message': responseData['response'],
            'time': DateTime.now().toLocal().toString(),
            'sender': 'bot',
          });
        });
        _scrollToBottom(); // 機器人回覆後自動滾動至底部
      } else {
        setState(() {
          _messages.add({
            'message': 'Error: ${response.statusCode}',
            'time': DateTime.now().toLocal().toString(),
            'sender': 'bot',
          });
        });
        _scrollToBottom(); // 錯誤訊息後自動滾動至底部
      }
    } catch (e) {
      setState(() {
        _messages.add({
          'message': 'Error: $e',
          'time': DateTime.now().toLocal().toString(),
          'sender': 'bot',
        });
      });
      _scrollToBottom(); // 錯誤訊息後自動滾動至底部
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('NTOU Navigator'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController, // 將 ScrollController 綁定至 ListView
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isUser = message['sender'] == 'user';
                final alignment =
                    isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start;
                final color = isUser ? Colors.blue[100] : Colors.grey[300];

                final formattedTime = DateFormat('HH:mm')
                    .format(DateTime.parse(message['time'] ?? ''));

                return Column(
                  crossAxisAlignment: alignment,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 10),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(message['message'] ?? ''),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        formattedTime,
                        style:
                            const TextStyle(fontSize: 10, color: Colors.grey),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(
                top: 8, bottom: 16.0, left: 19), // Adjust the padding as needed
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      labelText: 'Enter a message',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () {
                    final message = _controller.text;
                    if (message.isNotEmpty) {
                      sendMessage(message);
                      _controller.clear();
                    }
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
