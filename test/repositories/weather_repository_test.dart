import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:weather_app/services/weather_service.dart';

import '../helpers/weather_test_data.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late WeatherService weatherService;

  const apiKey = 'cb288425569c4c8db0164139261106';
  const baseUrl = 'https://api.weatherapi.com/v1';

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: baseUrl));
    dioAdapter = DioAdapter(dio: dio);
    weatherService = WeatherService(dio: dio);
  });

  group('WeatherService.getWeather', () {
    test('returns WeatherData on success', () async {
      dioAdapter.onGet(
        '/forecast.json',
            (server) => server.reply(200, buildWeatherApiResponse()),
        queryParameters: {
          'key': apiKey,
          'q': 'Ulaanbaatar',
          'days': 7,
          'aqi': 'no',
          'alerts': 'no',
          'lang': 'mn',
        },
      );

      final result = await weatherService.getWeather('Ulaanbaatar');

      expect(result.cityName, 'Ulaanbaatar');
      expect(result.country, 'Mongolia');
      expect(result.tempC, 21.5);
      expect(result.description, 'Sunny');
      expect(result.daily, hasLength(1));
    });

    test('returns correct temperature values', () async {
      dioAdapter.onGet(
        '/forecast.json',
            (server) => server.reply(
          200,
          buildWeatherApiResponse(tempC: -15.0, description: 'Blizzard'),
        ),
        queryParameters: {
          'key': apiKey,
          'q': 'Ulaanbaatar',
          'days': 7,
          'aqi': 'no',
          'alerts': 'no',
          'lang': 'mn',
        },
      );

      final result = await weatherService.getWeather('Ulaanbaatar');

      expect(result.tempC, -15.0);
      expect(result.description, 'Blizzard');
    });

    test('throws Mongolian message when city not found', () async {
      dioAdapter.onGet(
        '/forecast.json',
            (server) => server.reply(400, {
          'error': {'message': 'No matching location found.'}
        }),
        queryParameters: {
          'key': apiKey,
          'q': 'UnknownCity',
          'days': 7,
          'aqi': 'no',
          'alerts': 'no',
          'lang': 'mn',
        },
      );

      expect(
            () => weatherService.getWeather('UnknownCity'),
        throwsA(equals('No matching location found.')),
      );
    });

    test('throws Mongolian API key error on 401', () async {
      dioAdapter.onGet(
        '/forecast.json',
            (server) => server.reply(401, {
          'error': {'message': 'API key is invalid.'}
        }),
        queryParameters: {
          'key': apiKey,
          'q': 'Ulaanbaatar',
          'days': 7,
          'aqi': 'no',
          'alerts': 'no',
          'lang': 'mn',
        },
      );

      expect(
            () => weatherService.getWeather('Ulaanbaatar'),
        throwsA(equals('API түлхүүр буруу эсвэл идэвхгүй байна')),
      );
    });
  });

  group('WeatherService.searchCities', () {
    test('returns empty list when query is less than 2 characters', () async {
      final result = await weatherService.searchCities('U');
      expect(result, isEmpty);
    });

    test('returns empty list for empty query', () async {
      final result = await weatherService.searchCities('');
      expect(result, isEmpty);
    });

    test('returns cities on success', () async {
      dioAdapter.onGet(
        '/search.json',
            (server) => server.reply(200, [buildLocationJson()]),
        queryParameters: {'key': apiKey, 'q': 'Ulaanbaatar'},
      );

      final result = await weatherService.searchCities('Ulaanbaatar');

      expect(result, hasLength(1));
      expect(result.first.name, 'Ulaanbaatar');
      expect(result.first.country, 'Mongolia');
      expect(result.first.displayName, 'Ulaanbaatar, Mongolia');
    });

    test('trims whitespace from query before sending request', () async {
      dioAdapter.onGet(
        '/search.json',
            (server) => server.reply(200, [buildLocationJson()]),
        queryParameters: {'key': apiKey, 'q': 'Ulaanbaatar'},
      );

      final result = await weatherService.searchCities('  Ulaanbaatar  ');

      expect(result, hasLength(1));
      expect(result.first.name, 'Ulaanbaatar');
    });

    test('returns multiple cities', () async {
      dioAdapter.onGet(
        '/search.json',
            (server) => server.reply(200, [
          buildLocationJson(name: 'Ulaanbaatar', country: 'Mongolia'),
          buildLocationJson(name: 'Tokyo', country: 'Japan', lat: 35.68, lon: 139.69),
        ]),
        queryParameters: {'key': apiKey, 'q': 'test'},
      );

      final result = await weatherService.searchCities('test');

      expect(result, hasLength(2));
    });

    test('returns empty list on network error', () async {
      dioAdapter.onGet(
        '/search.json',
            (server) => server.reply(500, {}),
        queryParameters: {'key': apiKey, 'q': 'Ulaanbaatar'},
      );

      final result = await weatherService.searchCities('Ulaanbaatar');

      expect(result, isEmpty);
    });
  });
}