import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/providers/weather_providers.dart';
import 'package:weather_app/screens/home_screen.dart';

import '../helpers/weather_test_data.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  Widget buildTestApp({required List<Override> overrides}) {
    return ProviderScope(
      overrides: overrides,
      child: const MaterialApp(home: HomeScreen()),
    );
  }

  group('HomeScreen - app bar', () {
    testWidgets('shows app title', (tester) async {
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
    });

    testWidgets('shows subtitle text', (tester) async {
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

      expect(find.text('Дэлхийн аль ч хотын цаг агаар'), findsOneWidget);
    });
  });

  group('HomeScreen - countries section', () {
    testWidgets('shows countries section header', (tester) async {
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

      expect(find.text('Улс орнууд'), findsOneWidget);
    });

    testWidgets('shows loading indicators while fetching weather',
            (tester) async {
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

          expect(find.byType(CircularProgressIndicator), findsWidgets);
        });

    testWidgets('shows error state when weather fetch fails', (tester) async {
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

      expect(find.text('Алдаа гарлаа'), findsWidgets);
      expect(find.byIcon(Icons.error_outline), findsWidgets);
    });

    testWidgets('shows weather data when fetch succeeds', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            weatherProvider.overrideWith((ref, query) async {
              return buildTestWeatherData(
                cityName: query,
                tempC: 22,
                description: 'Sunny',
              );
            }),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Sunny'), findsWidgets);
      expect(find.text('22°C'), findsWidgets);
    });
  });

  group('HomeScreen - search bar', () {
    testWidgets('shows search bar', (tester) async {
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

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('search results hidden when query is short', (tester) async {
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

      final textField = find.byType(TextField);
      await tester.tap(textField);
      await tester.enterText(textField, 'U');
      await tester.pumpAndSettle();

      expect(find.byType(ListView), findsNothing);
    });
  });

  group('HomeScreen - favorites section', () {
    testWidgets('favorites section is hidden when list is empty',
            (tester) async {
          await tester.pumpWidget(
            buildTestApp(
              overrides: [
                weatherProvider.overrideWith((ref, query) {
                  return Completer<WeatherData>().future;
                }),
              ],
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Дуртай хотууд'), findsNothing);
        });
  });

  group('HomeScreen - most viewed section', () {
    testWidgets('most viewed section is hidden when list is empty',
            (tester) async {
          await tester.pumpWidget(
            buildTestApp(
              overrides: [
                weatherProvider.overrideWith((ref, query) {
                  return Completer<WeatherData>().future;
                }),
              ],
            ),
          );

          await tester.pumpAndSettle();

          expect(find.text('Сүүлд үзсэн'), findsNothing);
        });
  });
}