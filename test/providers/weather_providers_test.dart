import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/providers/weather_providers.dart';
import 'package:weather_app/services/weather_service.dart';

import '../helpers/weather_test_data.dart';

class MockWeatherService extends Mock implements WeatherService {}

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  ProviderContainer createContainer({WeatherService? weatherService}) {
    final container = ProviderContainer(
      overrides: [
        if (weatherService != null)
          weatherServiceProvider.overrideWith((ref) => weatherService),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('countriesProvider', () {
    test('returns non-empty countries list', () {
      final container = createContainer();
      final countries = container.read(countriesProvider);

      expect(countries, isNotEmpty);
    });

    test('first country is Mongolia', () {
      final container = createContainer();
      final countries = container.read(countriesProvider);

      expect(countries.first['name'], 'Монгол');
      expect(countries.first['query'], 'Ulaanbaatar');
      expect(countries.first['flag'], '🇲🇳');
    });

    test('contains 10 countries', () {
      final container = createContainer();
      final countries = container.read(countriesProvider);

      expect(countries, hasLength(10));
    });

    test('each country has name, query, and flag fields', () {
      final container = createContainer();
      final countries = container.read(countriesProvider);

      for (final country in countries) {
        expect(country.containsKey('name'), isTrue);
        expect(country.containsKey('query'), isTrue);
        expect(country.containsKey('flag'), isTrue);
      }
    });
  });

  group('searchQueryProvider', () {
    test('initial value is empty string', () {
      final container = createContainer();

      expect(container.read(searchQueryProvider), '');
    });

    test('can update search query', () {
      final container = createContainer();

      container.read(searchQueryProvider.notifier).state = 'Tokyo';

      expect(container.read(searchQueryProvider), 'Tokyo');
    });
  });

  group('searchResultsVisibleProvider', () {
    test('hidden when query is empty', () {
      final container = createContainer();

      expect(container.read(searchResultsVisibleProvider), isFalse);
    });

    test('hidden when query has 1 character', () {
      final container = createContainer();
      container.read(searchQueryProvider.notifier).state = 'U';

      expect(container.read(searchResultsVisibleProvider), isFalse);
    });

    test('visible when query has 2 or more characters', () {
      final container = createContainer();
      container.read(searchQueryProvider.notifier).state = 'Ul';

      expect(container.read(searchResultsVisibleProvider), isTrue);
    });

    test('trims whitespace before checking length', () {
      final container = createContainer();
      container.read(searchQueryProvider.notifier).state = '  U  ';

      expect(container.read(searchResultsVisibleProvider), isFalse);
    });
  });

  group('searchResultsProvider', () {
    test('returns empty list when query is too short', () async {
      final service = MockWeatherService();
      final container = createContainer(weatherService: service);

      container.read(searchQueryProvider.notifier).state = 'U';

      final result = await container.read(searchResultsProvider.future);

      expect(result, isEmpty);
      verifyNever(() => service.searchCities(any()));
    });

    test('returns cities from service when query is valid', () async {
      final service = MockWeatherService();
      final city = buildTestCity();
      final container = createContainer(weatherService: service);

      when(() => service.searchCities('Ulaanbaatar'))
          .thenAnswer((_) async => [city]);

      container.read(searchQueryProvider.notifier).state = ' Ulaanbaatar ';

      final result = await container.read(searchResultsProvider.future);

      expect(result, hasLength(1));
      expect(result.first.name, 'Ulaanbaatar');
      verify(() => service.searchCities('Ulaanbaatar')).called(1);
    });

    test('returns empty list when service returns no results', () async {
      final service = MockWeatherService();
      final container = createContainer(weatherService: service);

      when(() => service.searchCities('xyz123'))
          .thenAnswer((_) async => []);

      container.read(searchQueryProvider.notifier).state = 'xyz123';

      final result = await container.read(searchResultsProvider.future);

      expect(result, isEmpty);
    });
  });

  group('weatherProvider', () {
    test('returns weather data on success', () async {
      final service = MockWeatherService();
      final weather = buildTestWeatherData();
      final container = createContainer(weatherService: service);

      when(() => service.getWeather('Ulaanbaatar'))
          .thenAnswer((_) async => weather);

      final result =
      await container.read(weatherProvider('Ulaanbaatar').future);

      expect(result.cityName, 'Ulaanbaatar');
      expect(result.tempC, 21.5);
    });

    test('throws error when service fails', () async {
      final service = MockWeatherService();
      final container = createContainer(weatherService: service);

      when(() => service.getWeather('UnknownCity'))
          .thenThrow('No matching location found.');

      expect(
        container.read(weatherProvider('UnknownCity').future),
        throwsA('No matching location found.'),
      );
    });
  });

  group('favoritesProvider', () {
    test('starts with empty list', () async {
      final container = createContainer();
      final favorites = await container.read(favoritesProvider.future);

      expect(favorites, isEmpty);
    });

    test('adds city to favorites', () async {
      final container = createContainer();
      final city = buildTestCity();

      await container.read(favoritesProvider.future);
      await container.read(favoritesProvider.notifier).toggle(city);

      final favorites = container.read(favoritesProvider).value;
      expect(favorites, hasLength(1));
      expect(favorites!.first.name, 'Ulaanbaatar');
    });

    test('removes city when toggled again', () async {
      final container = createContainer();
      final city = buildTestCity();

      await container.read(favoritesProvider.future);
      await container.read(favoritesProvider.notifier).toggle(city);
      await container.read(favoritesProvider.notifier).toggle(city);

      final favorites = container.read(favoritesProvider).value;
      expect(favorites, isEmpty);
    });

    test('isFavorite returns false for non-favorite city', () async {
      final container = createContainer();
      final city = buildTestCity();

      await container.read(favoritesProvider.future);

      expect(
        await container.read(favoritesProvider.notifier).isFavorite(city),
        isFalse,
      );
    });

    test('isFavorite returns true after adding city', () async {
      final container = createContainer();
      final city = buildTestCity();

      await container.read(favoritesProvider.future);
      await container.read(favoritesProvider.notifier).toggle(city);

      expect(
        await container.read(favoritesProvider.notifier).isFavorite(city),
        isTrue,
      );
    });

    test('can add multiple cities', () async {
      final container = createContainer();
      final city1 = buildTestCity();
      final city2 = buildTestCity(name: 'Tokyo', country: 'Japan');

      await container.read(favoritesProvider.future);
      await container.read(favoritesProvider.notifier).toggle(city1);
      await container.read(favoritesProvider.notifier).toggle(city2);

      final favorites = container.read(favoritesProvider).value;
      expect(favorites, hasLength(2));
    });
  });

  group('mostViewedProvider', () {
    test('starts with empty list', () async {
      final container = createContainer();
      final mostViewed = await container.read(mostViewedProvider.future);

      expect(mostViewed, isEmpty);
    });

    test('records viewed city', () async {
      final container = createContainer();
      final city = buildTestCity();

      await container.read(mostViewedProvider.future);
      await container.read(mostViewedProvider.notifier).recordView(city);

      final mostViewed = container.read(mostViewedProvider).value;
      expect(mostViewed, hasLength(1));
      expect(mostViewed!.first.name, 'Ulaanbaatar');
    });

    test('latest viewed city is first', () async {
      final container = createContainer();
      final ulaanbaatar = buildTestCity();
      final tokyo = buildTestCity(name: 'Tokyo', country: 'Japan');

      await container.read(mostViewedProvider.future);
      await container.read(mostViewedProvider.notifier).recordView(ulaanbaatar);
      await container.read(mostViewedProvider.notifier).recordView(tokyo);

      final mostViewed = container.read(mostViewedProvider).value;
      expect(mostViewed!.first.name, 'Tokyo');
      expect(mostViewed.last.name, 'Ulaanbaatar');
    });

    test('viewing same city moves it to top', () async {
      final container = createContainer();
      final ulaanbaatar = buildTestCity();
      final tokyo = buildTestCity(name: 'Tokyo', country: 'Japan');

      await container.read(mostViewedProvider.future);
      await container.read(mostViewedProvider.notifier).recordView(ulaanbaatar);
      await container.read(mostViewedProvider.notifier).recordView(tokyo);
      await container.read(mostViewedProvider.notifier).recordView(ulaanbaatar);

      final mostViewed = container.read(mostViewedProvider).value;
      expect(mostViewed, hasLength(2));
      expect(mostViewed!.first.name, 'Ulaanbaatar');
    });

    test('keeps only latest 10 cities', () async {
      final container = createContainer();

      await container.read(mostViewedProvider.future);

      for (var i = 0; i < 12; i++) {
        await container.read(mostViewedProvider.notifier).recordView(
          buildTestCity(name: 'City $i', country: 'Country'),
        );
      }

      final mostViewed = container.read(mostViewedProvider).value;
      expect(mostViewed, hasLength(10));
      expect(mostViewed!.first.name, 'City 11');
    });
  });
}