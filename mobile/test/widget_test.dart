// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:mobile/main.dart';
import 'package:mobile/screens/intro_screen.dart';
import 'package:mobile/screens/main_menu_screen.dart';

void main() {
  testWidgets('App starts with intro screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the intro screen is displayed.
    expect(find.byType(IntroScreen), findsOneWidget);
    
    // Verify the game title is shown.
    expect(find.text('VIBE CODING'), findsOneWidget);
    expect(find.text('G A M E'), findsOneWidget);
  });
}
