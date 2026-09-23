import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:paylite/features/auth/presentation/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders Customer ID and PIN input fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    expect(find.text('Welcome to PayLite'), findsOneWidget);
    expect(find.text('Customer ID'), findsOneWidget);
    expect(find.text('App PIN / Passcode'), findsOneWidget);
    expect(find.text('Sign In & Bind Device'), findsOneWidget);
  });
}
