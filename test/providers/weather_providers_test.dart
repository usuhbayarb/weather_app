import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather_app/models/weather_model.dart';
import 'package:weather_app/providers/weather_providers.dart';
import 'package:weather_app/services/weather_service.dart';

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

  City buildCity({
    String name = 'Ulaanbaatar',
    String country = 'Mongolia',
    double lat = 47.92,
    double lon = 106.92,
  }) {
    return City(
      name: name,
      country: country,
      lat: lat,
      lon: lon,
    );
  }

  WeatherData buildWeatherData({
    String cityName = 'Ulaanbaatar',
    String country = 'Mongolia',
  }) {
    final current = {
      'temp_c': 21.5,
      'feelslike_c': 20.8,
      'humidity': 45,
      'wind_kph': 12.3,
      'condition': {
        'text': 'Sunny',
        'icon': '//cdn.weatherapi.com/weather/64x64/day/113.png',
      },
      'uv': 4.0,
      'vis_km': 10.0,
      'pressure_mb': 1012.0,
    };

    final location = {
      'name': cityName,
      'country': country,
      'lat': 47.92,
      'lon': 106.92,
    };

    final forecast = [
      {
        'date': '2026-06-15',
        'day': {
          'maxtemp_c': 24.0,
          'mintemp_c': 12.0,
          'condition': {
            'text': 'Sunny',
            'icon': '//cdn.weatherapi.com/weather/64x64/day/113.png',
          },
          'daily_chance_of_rain': 10,
          'avghumidity': 50,
          'maxwind_kph': 15.0,
          'uv': 5.0,
          'avgvis_km': 10.0,
          'totalprecip_mm': 0.0,
          'daily_chance_of_snow': 0,
        },
      },
    ];

    return WeatherData.fromJson(current, location, forecast);
  }

  group('countriesProvider', () {
    test('returns popular countries list', () {
      final container = createContainer();

      final countries = container.read(countriesProvider);

      expect(countries, isNotEmpty);
      expect(countries.first['name'], 'Монгол');
      expect(countries.first['query'], 'Ulaanbaatar');
      expect(countries.first['flag'], '🇲🇳');
    });
  });

  group('searchQueryProvider and searchResultsVisibleProvider', () {
    test('search results are hidden when query has less than 2 characters', () {
      final container = createContainer();

      container.read(searchQueryProvider.notifier).state = 'U';

      expect(container.read(searchResultsVisibleProvider), isFalse);
    });

    test('search results are visible when query has at least 2 characters', () {
      final container = createContainer();

      container.read(searchQueryProvider.notifier).state = 'Ul';

      expect(container.read(searchResultsVisibleProvider), isTrue);
    });

    test('search results visibility trims query whitespace', () {
      final container = createContainer();

      container.read(searchQueryProvider.notifier).state = '  U  ';

      expect(container.read(searchResultsVisibleProvider), isFalse);
    });
  });

  group('searchResultsProvider', () {
    test('returns empty list when query has less than 2 characters', () async {
      final service = MockWeatherService();
      final container = createContainer(weatherService: service);

      container.read(searchQueryProvider.notifier).state = 'U';

      final result = await container.read(searchResultsProvider.future);

      expect(result, isEmpty);
      verifyNever(() => service.searchCities(any()));
    });

    test('returns cities from weather service when query is valid', () async {
      final service = MockWeatherService();
      final city = buildCity();
      final container = createContainer(weatherService: service);

      when(() => service.searchCities('Ulaanbaatar')).thenAnswer(
            (_) async => [city],
      );

      container.read(searchQueryProvider.notifier).state = ' Ulaanbaatar ';

      final result = await container.read(searchResultsProvider.future);

      expect(result, hasLength(1));
      expect(result.first.name, 'Ulaanbaatar');
      expect(result.first.country, 'Mongolia');

      verify(() => service.searchCities('Ulaanbaatar')).called(1);
    });
  });

  group('weatherProvider', () {
    test('returns weather data when service succeeds', () async {
      final service = MockWeatherService();
      final weather = buildWeatherData();
      final container = createContainer(weatherService: service);

      when(() => service.getWeather('Ulaanbaatar')).thenAnswer(
            (_) async => weather,
      );

      final result = await container.read(
        weatherProvider('Ulaanbaatar').future,
      );

      expect(result.cityName, 'Ulaanbaatar');
      expect(result.country, 'Mongolia');
      expect(result.tempC, 21.5);

      verify(() => service.getWeather('Ulaanbaatar')).called(1);
    });

    test('throws error when service fails', () async {
      final service = MockWeatherService();
      final container = createContainer(weatherService: service);

      when(() => service.getWeather('UnknownCity')).thenThrow(
        'No matching location found.',
      );

      expect(
        container.read(weatherProvider('UnknownCity').future),
        throwsA('No matching location found.'),
      );
    });
  });

  group('favoritesProvider', () {
    test('starts with empty favorites list', () async {
      final container = createContainer();

      final favorites = await container.read(favoritesProvider.future);

      expect(favorites, isEmpty);
    });

    test('toggles city as favorite and removes it when toggled again', () async {
      final container = createContainer();
      final city = buildCity();

      await container.read(favoritesProvider.future);

      await container.read(favoritesProvider.notifier).toggle(city);

      final added = container.read(favoritesProvider).value;

      expect(added, isNotNull);
      expect(added, hasLength(1));
      expect(added!.first.name, 'Ulaanbaatar');

      await container.read(favoritesProvider.notifier).toggle(city);

      final removed = container.read(favoritesProvider).value;

      expect(removed, isNotNull);
      expect(removed, isEmpty);
    });

    test('checks whether city is favorite', () async {
      final container = createContainer();
      final city = buildCity();

      await container.read(favoritesProvider.future);

      expect(
        await container.read(favoritesProvider.notifier).isFavorite(city),
        isFalse,
      );

      await container.read(favoritesProvider.notifier).toggle(city);

      expect(
        await container.read(favoritesProvider.notifier).isFavorite(city),
        isTrue,
      );
    });
  });

  group('mostViewedProvider', () {
    test('starts with empty most viewed list', () async {
      final container = createContainer();

      final mostViewed = await container.read(mostViewedProvider.future);

      expect(mostViewed, isEmpty);
    });

    test('records recently viewed cities with latest city first', () async {
      final container = createContainer();

      final ulaanbaatar = buildCity();
      final tokyo = buildCity(
        name: 'Tokyo',
        country: 'Japan',
        lat: 35.68,
        lon: 139.69,
      );

      await container.read(mostViewedProvider.future);

      await container.read(mostViewedProvider.notifier).recordView(ulaanbaatar);
      await container.read(mostViewedProvider.notifier).recordView(tokyo);

      final mostViewed = container.read(mostViewedProvider).value;

      expect(mostViewed, isNotNull);
      expect(mostViewed, hasLength(2));
      expect(mostViewed!.first.name, 'Tokyo');
      expect(mostViewed.last.name, 'Ulaanbaatar');
    });

    test('keeps only latest 10 viewed cities', () async {
      final container = createContainer();

      await container.read(mostViewedProvider.future);

      for (var i = 0; i < 12; i++) {
        await container.read(mostViewedProvider.notifier).recordView(
          buildCity(
            name: 'City $i',
            country: 'Country',
            lat: i.toDouble(),
            lon: i.toDouble(),
          ),
        );
      }

      final mostViewed = container.read(mostViewedProvider).value;

      expect(mostViewed, isNotNull);
      expect(mostViewed, hasLength(10));
      expect(mostViewed!.first.name, 'City 11');
      expect(mostViewed.last.name, 'City 2');
    });
  });
}