import 'package:flutter_test/flutter_test.dart';
import 'package:project/main.dart'; // 確保導入正確

void main() {
  testWidgets('MyApp has a title and message', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    final titleFinder = find.text('My App');
    final messageFinder = find.text('Hello, world!');

    expect(titleFinder, findsOneWidget);
    expect(messageFinder, findsOneWidget);
  });
}
