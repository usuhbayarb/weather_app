import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/providers/weather_providers.dart';
import 'package:weather_app/screens/weather_detail_screen.dart';
import 'package:weather_app/models/weather_model.dart';
import '../helpers/weather_test_data.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('mn');
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp({
    required List<Override> overrides,
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: WeatherDetailScreen(
          city: buildTestCity(),
        ),
      ),
    );
  }

  group('WeatherDetailScreen', () {
    testWidgets('shows loading state', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            weatherProvider.overrideWith((ref, query) {
              return Completer<WeatherData>().future;
            }),
          ],
        ),
      );

      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows error state', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            weatherProvider.overrideWith((ref, query) async {
              throw 'Network error';
            }),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.error_outline), findsOneWidget);
      expect(find.text('Network error'), findsOneWidget);
      expect(find.text('Дахин оролдох'), findsOneWidget);
    });

    testWidgets('shows success state', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            weatherProvider.overrideWith((ref, query) async {
              return buildTestWeatherData();
            }),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Ulaanbaatar'), findsOneWidget);
      expect(find.text('Mongolia'), findsOneWidget);
      expect(find.text('22°C'), findsOneWidget);
      expect(find.text('Sunny'), findsWidgets);
      expect(find.text('Мэдрэмж 21°C'), findsOneWidget);
      expect(find.text('Чийгшил'), findsOneWidget);
      expect(find.text('Салхи'), findsOneWidget);
      expect(find.text('7 ХОНОГИЙН ТААМАГ'), findsOneWidget);
    });
  });
}