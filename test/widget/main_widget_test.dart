import 'package:flutter_test/flutter_test.dart';
import 'package:paylite/main.dart';

void main() {
  testWidgets('PayLiteApp shows hello greeting and title', (WidgetTester tester) async {
    await tester.pumpWidget(const PayLiteApp());

    expect(find.text('PayLite'), findsOneWidget);
    expect(find.text('Hello to my PayLite project'), findsOneWidget);
  });
}
