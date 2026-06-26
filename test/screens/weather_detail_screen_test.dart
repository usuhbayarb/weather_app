import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/providers/weather_providers.dart';
import 'package:weather_app/screens/weather_detail_screen.dart';

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
    City? city,
  }) {
    return ProviderScope(
      overrides: overrides,
      child: MaterialApp(
        home: WeatherDetailScreen(
          city: city ?? buildTestCity(),
        ),
      ),
    );
  }

  group('WeatherDetailScreen - loading & error', () {
    testWidgets('shows loading indicator while fetching weather',
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

          expect(find.byType(CircularProgressIndicator), findsOneWidget);
        });

    testWidgets('shows error icon and message on failure', (tester) async {
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
    });

    testWidgets('shows retry button on error', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            weatherProvider.overrideWith((ref, query) async {
              throw 'Цаг агаарын мэдээлэл авахад алдаа гарлаа';
            }),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Дахин оролдох'), findsOneWidget);
    });
  });

  group('WeatherDetailScreen - success state', () {
    testWidgets('shows city name and country', (tester) async {
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
    });

    testWidgets('shows temperature and description', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          overrides: [
            weatherProvider.overrideWith((ref, query) async {
              return buildTestWeatherData(tempC: 21.5, description: 'Sunny');
            }),
          ],
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('22°C'), findsOneWidget);
      expect(find.text('Sunny'), findsWidgets);
    });

    testWidgets('shows feels like temperature', (tester) async {
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

      expect(find.text('Мэдрэмж 21°C'), findsOneWidget);
    });

    testWidgets('shows weather stats - humidity, wind, visibility, pressure',
            (tester) async {
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

          expect(find.text('Чийгшил'), findsOneWidget);
          expect(find.text('Салхи'), findsOneWidget);
          expect(find.text('Харалт'), findsOneWidget);
          expect(find.text('Даралт'), findsOneWidget);
        });

    testWidgets('shows 7-day forecast section', (tester) async {
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

      expect(find.text('7 ХОНОГИЙН ТААМАГ'), findsOneWidget);
    });
  });

  group('WeatherDetailScreen - favorite button', () {
    testWidgets('shows unfilled favorite icon when city is not favorite',
            (tester) async {
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

          expect(find.byIcon(Icons.favorite_border), findsOneWidget);
        });

    testWidgets('shows filled favorite icon when city is favorite',
            (tester) async {
          final city = buildTestCity();

          await tester.pumpWidget(
            buildTestApp(
              city: city,
              overrides: [
                weatherProvider.overrideWith((ref, query) async {
                  return buildTestWeatherData();
                }),
                favoritesProvider.overrideWith(() {
                  final notifier = FavoritesNotifier();
                  return notifier;
                }),
              ],
            ),
          );

          await tester.pumpAndSettle();

          // Favorite товч дарна
          await tester.tap(find.byIcon(Icons.favorite_border));
          await tester.pumpAndSettle();

          expect(find.byIcon(Icons.favorite), findsOneWidget);
        });

    testWidgets('toggles favorite icon when tapped twice', (tester) async {
      final city = buildTestCity();

      await tester.pumpWidget(
        buildTestApp(
          city: city,
          overrides: [
            weatherProvider.overrideWith((ref, query) async {
              return buildTestWeatherData();
            }),
          ],
        ),
      );

      await tester.pumpAndSettle();

      // Нэмэх
      await tester.tap(find.byIcon(Icons.favorite_border));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite), findsOneWidget);

      // Хасах
      await tester.tap(find.byIcon(Icons.favorite));
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });
  });

  group('WeatherDetailScreen - day detail sheet', () {
    testWidgets('opens day detail sheet when forecast row is tapped',
            (tester) async {
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

          // Forecast row-г tap хийнэ
          await tester.tap(find.text('Sunny').last);
          await tester.pumpAndSettle();

          // Bottom sheet нээгдсэн эсэхийг шалгана
          expect(find.text('Чийгшил'), findsWidgets);
          expect(find.text('Хаах'), findsOneWidget);
        });

    testWidgets('closes day detail sheet when close button is tapped',
            (tester) async {
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

          await tester.tap(find.text('Sunny').last);
          await tester.pumpAndSettle();

          expect(find.text('Хаах'), findsOneWidget);

          await tester.tap(find.text('Хаах'));
          await tester.pumpAndSettle();

          expect(find.text('Хаах'), findsNothing);
        });
  });
}