import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_model.dart';

import '../helpers/weather_test_data.dart';

void main() {
  group('WeatherData.fromJson', () {
    test('parses basic weather data correctly', () {
      final weather = WeatherData.fromJson(
        buildCurrentWeatherJson(),
        buildLocationJson(),
        buildForecastJson(),
      );

      expect(weather.cityName, 'Ulaanbaatar');
      expect(weather.country, 'Mongolia');
      expect(weather.lat, 47.92);
      expect(weather.lon, 106.92);
      expect(weather.tempC, 21.5);
      expect(weather.feelsLike, 20.8);
      expect(weather.humidity, 45);
      expect(weather.windSpeed, 12.3);
      expect(weather.description, 'Sunny');
      expect(weather.icon, 'https://cdn.weatherapi.com/weather/64x64/day/113.png');
      expect(weather.uvIndex, 4);
      expect(weather.visibility, 10.0);
      expect(weather.pressure, 1012);
    });

    test('parses forecast list correctly', () {
      final weather = WeatherData.fromJson(
        buildCurrentWeatherJson(),
        buildLocationJson(),
        buildForecastJson(),
      );

      expect(weather.daily, hasLength(1));
      expect(weather.daily.first.maxTemp, 24.0);
      expect(weather.daily.first.minTemp, 12.0);
      expect(weather.daily.first.description, 'Sunny');
      expect(weather.daily.first.chanceOfRain, 10);
      expect(weather.daily.first.humidity, 50);
    });

    test('parses negative temperature correctly', () {
      final weather = WeatherData.fromJson(
        buildCurrentWeatherJson(tempC: -20.0, feelsLikeC: -25.0),
        buildLocationJson(),
        buildForecastJson(),
      );

      expect(weather.tempC, -20.0);
      expect(weather.feelsLike, -25.0);
    });

    test('parses weather data for different city', () {
      final weather = WeatherData.fromJson(
        buildCurrentWeatherJson(
          tempC: -5.2,
          feelsLikeC: -8.0,
          humidity: 70,
          conditionText: 'Snow',
        ),
        buildLocationJson(
          name: 'Tokyo',
          country: 'Japan',
          lat: 35.68,
          lon: 139.69,
        ),
        buildForecastJson(conditionText: 'Snow'),
      );

      expect(weather.cityName, 'Tokyo');
      expect(weather.country, 'Japan');
      expect(weather.tempC, -5.2);
      expect(weather.feelsLike, -8.0);
      expect(weather.humidity, 70);
      expect(weather.description, 'Snow');
    });

    test('icon url is prefixed with https:', () {
      final weather = WeatherData.fromJson(
        buildCurrentWeatherJson(
          icon: '//cdn.weatherapi.com/weather/64x64/day/113.png',
        ),
        buildLocationJson(),
        buildForecastJson(),
      );

      expect(weather.icon, startsWith('https://'));
    });
  });

  group('DailyForecast.fromJson', () {
    test('parses date correctly', () {
      final forecast = DailyForecast.fromJson(buildForecastJson().first);

      expect(forecast.date, DateTime.parse('2026-06-15'));
    });

    test('parses all forecast fields', () {
      final forecast = DailyForecast.fromJson(buildForecastJson().first);

      expect(forecast.maxTemp, 24.0);
      expect(forecast.minTemp, 12.0);
      expect(forecast.chanceOfRain, 10);
      expect(forecast.humidity, 50);
      expect(forecast.windSpeed, 15.0);
      expect(forecast.uvIndex, 5);
      expect(forecast.visibility, 10.0);
      expect(forecast.totalPrecipMm, 0.0);
      expect(forecast.chanceOfSnow, 0);
    });
  });

  group('City', () {
    test('parses city from json', () {
      final city = City.fromJson({
        'name': 'Tokyo',
        'country': 'Japan',
        'lat': 35.68,
        'lon': 139.69,
      });

      expect(city.name, 'Tokyo');
      expect(city.country, 'Japan');
      expect(city.lat, 35.68);
      expect(city.lon, 139.69);
    });

    test('displayName returns name and country combined', () {
      final city = City.fromJson({
        'name': 'Seoul',
        'country': 'South Korea',
        'lat': 37.56,
        'lon': 126.97,
      });

      expect(city.displayName, 'Seoul, South Korea');
    });

    test('toJson returns correct map', () {
      final city = City(
        name: 'Tokyo',
        country: 'Japan',
        lat: 35.68,
        lon: 139.69,
      );

      expect(city.toJson(), {
        'name': 'Tokyo',
        'country': 'Japan',
        'lat': 35.68,
        'lon': 139.69,
      });
    });

    test('fromJson and toJson are reversible', () {
      final original = {
        'name': 'Paris',
        'country': 'France',
        'lat': 48.85,
        'lon': 2.35,
      };

      final city = City.fromJson(original);
      expect(city.toJson(), original);
    });
  });
}
