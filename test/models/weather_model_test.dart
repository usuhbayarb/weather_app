import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_model.dart';

import '../helpers/weather_test_data.dart';

void main() {
  group('WeatherData.fromJson', () {
    test('parses weather data from API json', () {
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
      expect(
        weather.icon,
        'https://cdn.weatherapi.com/weather/64x64/day/113.png',
      );
      expect(weather.uvIndex, 4);
      expect(weather.visibility, 10.0);
      expect(weather.pressure, 1012);
      expect(weather.daily, hasLength(1));
      expect(weather.daily.first.maxTemp, 24.0);
      expect(weather.daily.first.minTemp, 12.0);
    });

    test('parses weather data with custom values', () {
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
        buildForecastJson(
          conditionText: 'Snow',
        ),
      );

      expect(weather.cityName, 'Tokyo');
      expect(weather.country, 'Japan');
      expect(weather.tempC, -5.2);
      expect(weather.feelsLike, -8.0);
      expect(weather.humidity, 70);
      expect(weather.description, 'Snow');
    });
  });

  group('City', () {
    test('parses city json and converts back to json', () {
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
      expect(city.displayName, 'Tokyo, Japan');

      expect(city.toJson(), {
        'name': 'Tokyo',
        'country': 'Japan',
        'lat': 35.68,
        'lon': 139.69,
      });
    });
  });
}
