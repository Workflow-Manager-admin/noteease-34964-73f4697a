import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:note_ease/main.dart';

void main() {
  testWidgets('NoteEase main screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const NoteEaseApp());

    // App bar title should be present
    expect(find.text('NoteEase'), findsOneWidget);

    // Check for floating action button
    expect(find.byType(FloatingActionButton), findsOneWidget);

    // Category filter chips should be present (including 'All')
    expect(find.byType(ChoiceChip), findsWidgets);
    expect(find.text('All'), findsOneWidget);

    // Search TextField should be present
    expect(find.byType(TextField), findsOneWidget);
  });
}
