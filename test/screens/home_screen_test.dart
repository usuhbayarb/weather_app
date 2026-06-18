import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/providers/weather_providers.dart';
import 'package:weather_app/screens/home_screen.dart';
import 'package:weather_app/models/weather_model.dart';
import '../helpers/weather_test_data.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp({
    required List<Override> overrides,
  }) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(
        home: HomeScreen(),
      ),
    );
  }

  group('HomeScreen', () {
    testWidgets('shows loading state from country weather cards', (tester) async {
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

      expect(find.textContaining('Цаг Агаар'), findsOneWidget);
      expect(find.text('Улс орнууд'), findsOneWidget);
      expect(find.text('Ачааллаж байна...'), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsWidgets);
    });

    testWidgets('shows error state from country weather cards', (tester) async {
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

      expect(find.textContaining('Цаг Агаар'), findsOneWidget);
      expect(find.text('Улс орнууд'), findsOneWidget);
      expect(find.text('Алдаа гарлаа'), findsWidgets);
      expect(find.byIcon(Icons.error_outline), findsWidgets);
    });

    testWidgets('shows success state from country weather cards', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            weatherProvider.overrideWith((ref, query) async {
              return buildTestWeatherData(
                cityName: query,
                country: 'Test Country',
                tempC: 22,
                description: 'Sunny',
              );
            }),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.textContaining('Цаг Агаар'), findsOneWidget);
      expect(find.text('Улс орнууд'), findsOneWidget);
      expect(find.text('Sunny'), findsWidgets);
      expect(find.text('22°C'), findsWidgets);
    });
  });
}