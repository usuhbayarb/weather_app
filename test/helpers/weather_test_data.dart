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

WeatherData buildTestWeatherData({
  String cityName = 'Ulaanbaatar',
  String country = 'Mongolia',
  double tempC = 21.5,
  String description = 'Sunny',
}) {
  return WeatherData(
    cityName: cityName,
    country: country,
    lat: 47.92,
    lon: 106.92,
    tempC: tempC,
    feelsLike: 20.8,
    humidity: 45,
    windSpeed: 12.3,
    description: description,
    icon: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
    uvIndex: 4,
    visibility: 10.0,
    pressure: 1012,
    daily: [
      DailyForecast(
        date: DateTime(2026, 6, 15),
        maxTemp: 24.0,
        minTemp: 12.0,
        description: 'Sunny',
        icon: 'https://cdn.weatherapi.com/weather/64x64/day/113.png',
        chanceOfRain: 10,
        humidity: 50,
        windSpeed: 15.0,
        uvIndex: 5,
        visibility: 10.0,
        totalPrecipMm: 0.0,
        chanceOfSnow: 0,
      ),
    ],
  );
}