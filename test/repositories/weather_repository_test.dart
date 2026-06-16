import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:weather_app/services/weather_service.dart';

void main() {
  late Dio dio;
  late DioAdapter dioAdapter;
  late WeatherService weatherService;

  const apiKey = 'cb288425569c4c8db0164139261106';

  final weatherResponse = {
    'location': {
      'name': 'Ulaanbaatar',
      'country': 'Mongolia',
      'lat': 47.92,
      'lon': 106.92,
    },
    'current': {
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
    },
    'forecast': {
      'forecastday': [
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
      ],
    },
  };

  setUp(() {
    dio = Dio(
      BaseOptions(
        baseUrl: 'https://api.weatherapi.com/v1',
      ),
    );

    dioAdapter = DioAdapter(dio: dio);
    weatherService = WeatherService(dio: dio);
  });

  group('WeatherService.getWeather', () {
    test('returns WeatherData when HTTP request succeeds', () async {
      dioAdapter.onGet(
        '/forecast.json',
            (server) => server.reply(200, weatherResponse),
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

    test('throws API error message when city is not found', () async {
      dioAdapter.onGet(
        '/forecast.json',
            (server) => server.reply(
          400,
          {
            'error': {
              'message': 'No matching location found.',
            },
          },
        ),
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

    test('throws API key error message for unauthorized response', () async {
      dioAdapter.onGet(
        '/forecast.json',
            (server) => server.reply(
          401,
          {
            'error': {
              'message': 'API key is invalid.',
            },
          },
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

      expect(
            () => weatherService.getWeather('Ulaanbaatar'),
        throwsA(equals('API түлхүүр буруу эсвэл идэвхгүй байна')),
      );
    });
  });

  group('WeatherService.searchCities', () {
    test('returns empty list when query has less than 2 characters', () async {
      final result = await weatherService.searchCities('U');

      expect(result, isEmpty);
    });

    test('returns cities when HTTP request succeeds', () async {
      dioAdapter.onGet(
        '/search.json',
            (server) => server.reply(
          200,
          [
            {
              'name': 'Ulaanbaatar',
              'country': 'Mongolia',
              'lat': 47.92,
              'lon': 106.92,
            },
          ],
        ),
        queryParameters: {
          'key': apiKey,
          'q': 'Ulaanbaatar',
        },
      );

      final result = await weatherService.searchCities('Ulaanbaatar');

      expect(result, hasLength(1));
      expect(result.first.name, 'Ulaanbaatar');
      expect(result.first.country, 'Mongolia');
    });
  });
}