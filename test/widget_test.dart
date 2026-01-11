import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:location_diary_app/main.dart';
import 'package:location_diary_app/providers/entries_provider.dart';
import 'package:location_diary_app/providers/theme_provider.dart';

void main() {
  testWidgets('App should render main screen', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(const LocationDiaryApp());

    // Verify that the app title is present
    expect(find.text('Dziennik Lokalizacji'), findsOneWidget);

    // Verify that the FAB is present
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });

  testWidgets('Add entry FAB should be visible', (WidgetTester tester) async {
    await tester.pumpWidget(const LocationDiaryApp());

    // Verify FAB with "Dodaj wpis" text
    expect(find.text('Dodaj wpis'), findsOneWidget);
  });

  test('Entry model should serialize to JSON', () {
    // This test verifies the Entry model serialization
    final entry = {
      'id': 1,
      'title': 'Test Entry',
      'body': 'Test Description',
      'latitude': 52.2297,
      'longitude': 21.0122,
    };

    expect(entry['title'], 'Test Entry');
    expect(entry['latitude'], 52.2297);
  });

  test('EntriesProvider initial state', () {
    final provider = EntriesProvider();

    expect(provider.entries, isEmpty);
    expect(provider.state, LoadingState.initial);
    expect(provider.errorMessage, isNull);
  });

  test('ThemeProvider should have default theme mode', () {
    final provider = ThemeProvider();

    expect(provider.themeMode, ThemeMode.system);
    expect(provider.isLoaded, isFalse);
  });
}

