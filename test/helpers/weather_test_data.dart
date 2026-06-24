import 'package:weather_app/models/weather_model.dart';

City buildTestCity({
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

Map<String, dynamic> buildCurrentWeatherJson({
  double tempC = 21.5,
  double feelsLikeC = 20.8,
  int humidity = 45,
  double windKph = 12.3,
  String conditionText = 'Sunny',
  String icon = '//cdn.weatherapi.com/weather/64x64/day/113.png',
  double uv = 4.0,
  double visibilityKm = 10.0,
  double pressureMb = 1012.0,
}) {
  return {
    'temp_c': tempC,
    'feelslike_c': feelsLikeC,
    'humidity': humidity,
    'wind_kph': windKph,
    'condition': {
      'text': conditionText,
      'icon': icon,
    },
    'uv': uv,
    'vis_km': visibilityKm,
    'pressure_mb': pressureMb,
  };
}

Map<String, dynamic> buildLocationJson({
  String name = 'Ulaanbaatar',
  String country = 'Mongolia',
  double lat = 47.92,
  double lon = 106.92,
}) {
  return {
    'name': name,
    'country': country,
    'lat': lat,
    'lon': lon,
  };
}

List<Map<String, dynamic>> buildForecastJson({
  String date = '2026-06-15',
  double maxTempC = 24.0,
  double minTempC = 12.0,
  String conditionText = 'Sunny',
  String icon = '//cdn.weatherapi.com/weather/64x64/day/113.png',
}) {
  return [
    {
      'date': date,
      'day': {
        'maxtemp_c': maxTempC,
        'mintemp_c': minTempC,
        'condition': {
          'text': conditionText,
          'icon': icon,
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
}

Map<String, dynamic> buildWeatherApiResponse({
  String cityName = 'Ulaanbaatar',
  String country = 'Mongolia',
  double tempC = 21.5,
  String description = 'Sunny',
}) {
  return {
    'location': buildLocationJson(
      name: cityName,
      country: country,
    ),
    'current': buildCurrentWeatherJson(
      tempC: tempC,
      conditionText: description,
    ),
    'forecast': {
      'forecastday': buildForecastJson(
        conditionText: description,
      ),
    },
  };
}

WeatherData buildTestWeatherData({
  String cityName = 'Ulaanbaatar',
  String country = 'Mongolia',
  double tempC = 21.5,
  String description = 'Sunny',
}) {
  return WeatherData.fromJson(
    buildCurrentWeatherJson(
      tempC: tempC,
      conditionText: description,
    ),
    buildLocationJson(
      name: cityName,
      country: country,
    ),
    buildForecastJson(
      conditionText: description,
    ),
  );
}
