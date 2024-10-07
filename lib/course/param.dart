class CourseParam {
  final List<String> weeks = [
    '星期一',
    '星期二',
    '星期三',
    '星期四',
    '星期五',
    '星期六',
    '星期日',
  ];

  final List<String> timeSlots = [
    "第0節\n06:20 - \n08:10",
    "第一節\n08:20 - \n09:10",
    "第二節\n09:20 - \n10:10",
    "第三節\n10:20 - \n11:10",
    "第四節\n11:15 - \n12:05",
    "第五節\n12:10 - \n13:00",
    "第六節\n13:10 - \n14:00",
    "第七節\n14:10 - \n15:00",
    "第八節\n15:10 - \n16:00",
    "第九節\n16:05 - \n16:55",
    "第十節\n17:30 - \n18:20",
    "第十一節\n 18:30 - \n 19:20",
    "第十二節\n 19:25 - \n 20:15",
    "第十三節\n 20:20 - \n 21:10",
    "第十四節\n 21:15 - \n 22:05",
  ];

  // 獲取課程詳細資訊
  String getCourseDetails(Map<String, dynamic> course) {
    return '''
    課程ID: ${course['Id']}
    教授: ${course['Professor']}
    系所: ${course['Department']}
    學校: ${course['School']}
    課程時間: ${course['SessionTime'].join(', ')}
    地點: ${course['Location'].join(', ')}
    ''';
  }
}
