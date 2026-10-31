import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:my_week/login_screen.dart';

void main() {
  testWidgets('LoginScreen renders My Week title and input fields', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    expect(find.text('My Week'), findsOneWidget);
    expect(find.text('Log in'), findsOneWidget);
    expect(find.text('Create account'), findsOneWidget);
  });
}
