import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:todo_app_flutterclass/main.dart';

void main() {
  testWidgets('Todo App Layout Test', (WidgetTester tester) async {
    await tester.pumpWidget(TaskManagerApp(isDarkMode: false)); // Pass default value for isDarkMode

    // Verify App Title
    expect(find.text("Task Manager"), findsOneWidget);

    // Format the date manually
    final DateTime now = DateTime.now();
    final String dateString = "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    expect(find.text(dateString), findsOneWidget);

    // Verify the presence of Floating Action Button (FAB)
    expect(find.byIcon(Icons.add), findsOneWidget); // Verify the presence of Floating Action Button (FAB)

    // Tap the '+' icon to trigger the event
    await tester.tap(find.byIcon(Icons.add)); // Tap the '+' icon to trigger the event

    await tester.pump();
  });
}
