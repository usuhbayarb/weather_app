import 'package:flutter_test/flutter_test.dart';
import 'package:weather_app/models/weather_model.dart';

void main() {
  group('WeatherData.fromJson', () {
    test('parses weather data from API json', () {
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
        'name': 'Ulaanbaatar',
        'country': 'Mongolia',
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

      final weather = WeatherData.fromJson(current, location, forecast);

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