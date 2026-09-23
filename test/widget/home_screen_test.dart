import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paylite/features/account/presentation/home_screen.dart';

void main() {
  testWidgets('HomeScreen renders balance card and all 4 quick action buttons', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: HomeScreen(),
        ),
      ),
    );

    // Initial pump
    await tester.pump();

    expect(find.text('PayLite'), findsWidgets);
    expect(find.text('Scan QR'), findsOneWidget);
    expect(find.text('Pay VPA'), findsOneWidget);
    expect(find.text('Request'), findsOneWidget);
    expect(find.text('Split Bill'), findsOneWidget);
  });
}
