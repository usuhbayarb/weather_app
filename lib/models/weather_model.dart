
class WeatherData {
  final String cityName;
  final String country;
  final double lat;
  final double lon;
  final double tempC;
  final double feelsLike;
  final int humidity;
  final double windSpeed;
  final String description;
  final String icon;
  final int uvIndex;
  final double visibility;
  final int pressure;
  final List<DailyForecast> daily;

  WeatherData({
    required this.cityName,
    required this.country,
    required this.lat,
    required this.lon,
    required this.tempC,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.description,
    required this.icon,
    required this.uvIndex,
    required this.visibility,
    required this.pressure,
    required this.daily,
  });

  factory WeatherData.fromJson(Map<String, dynamic> current, Map<String, dynamic> location, List<dynamic> forecast) {
    final cond = current['condition'];
    return WeatherData(
      cityName: location['name'] ?? '',
      country: location['country'] ?? '',
      lat: (location['lat'] as num).toDouble(),
      lon: (location['lon'] as num).toDouble(),
      tempC: (current['temp_c'] as num).toDouble(),
      feelsLike: (current['feelslike_c'] as num).toDouble(),
      humidity: current['humidity'] as int,
      windSpeed: (current['wind_kph'] as num).toDouble(),
      description: cond['text'] ?? '',
      icon: 'https:${cond['icon']}',
      uvIndex: (current['uv'] as num).toInt(),
      visibility: (current['vis_km'] as num).toDouble(),
      pressure: (current['pressure_mb'] as num).toInt(),
      daily: forecast.map((d) => DailyForecast.fromJson(d)).toList(),
    );
  }
}

class DailyForecast {
  final DateTime date;
  final double maxTemp;
  final double minTemp;
  final String description;
  final String icon;
  final int chanceOfRain;
  final int humidity;
  final double windSpeed;
  final int uvIndex;
  final double visibility;
  final double totalPrecipMm;
  final int chanceOfSnow;

  DailyForecast({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.description,
    required this.icon,
    required this.chanceOfRain,
    required this.humidity,
    required this.windSpeed,
    required this.uvIndex,
    required this.visibility,
    required this.totalPrecipMm,
    required this.chanceOfSnow,
  });

  factory DailyForecast.fromJson(Map<String, dynamic> json) {
    final day = json['day'];
    final cond = day['condition'];
    return DailyForecast(
      date: DateTime.parse(json['date']),
      maxTemp: (day['maxtemp_c'] as num).toDouble(),
      minTemp: (day['mintemp_c'] as num).toDouble(),
      description: cond['text'] ?? '',
      icon: 'https:${cond['icon']}',
      chanceOfRain: (day['daily_chance_of_rain'] as num).toInt(),
      humidity: (day['avghumidity'] as num).toInt(),
      windSpeed: (day['maxwind_kph'] as num).toDouble(),
      uvIndex: (day['uv'] as num).toInt(),
      visibility: (day['avgvis_km'] as num).toDouble(),
      totalPrecipMm: (day['totalprecip_mm'] as num).toDouble(),
      chanceOfSnow: (day['daily_chance_of_snow'] as num).toInt(),
    );
  }
}

class City {
  final String name;
  final String country;
  final double lat;
  final double lon;

  City({
    required this.name,
    required this.country,
    required this.lat,
    required this.lon,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      name: json['name'] ?? '',
      country: json['country'] ?? '',
      lat: (json['lat'] as num).toDouble(),
      lon: (json['lon'] as num).toDouble(),
    );
  }

  String get displayName => '$name, $country';

  Map<String, dynamic> toJson() => {
    'name': name,
    'country': country,
    'lat': lat,
    'lon': lon,
  };
}
