import 'package:dio/dio.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.weatherapi.com/v1';
  static const String _apiKey = 'cb288425569c4c8db0164139261106';

  final Dio _dio;

  WeatherService({Dio? dio})
      : _dio = dio ??
            Dio(
              BaseOptions(
                baseUrl: _baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                sendTimeout: const Duration(seconds: 15),
              ),
            );

  Future<WeatherData> getWeather(String query) async {
    try {
      final response = await _dio.get(
        '/forecast.json',
        queryParameters: {
          'key': _apiKey,
          'q': query,
          'days': 7,
          'aqi': 'no',
          'alerts': 'no',
          'lang': 'mn',
        },
      );

      final data = response.data as Map<String, dynamic>;

      return WeatherData.fromJson(
        data['current'] as Map<String, dynamic>,
        data['location'] as Map<String, dynamic>,
        data['forecast']['forecastday'] as List<dynamic>,
      );
    } on DioException catch (error) {
      final statusCode = error.response?.statusCode;
      final data = error.response?.data;

      if (statusCode == 401) {
        throw 'API түлхүүр буруу эсвэл идэвхгүй байна';
      }

      if (data is Map<String, dynamic> &&
          data['error'] is Map<String, dynamic> &&
          data['error']['message'] != null) {
        throw data['error']['message'].toString();
      }

      throw 'Цаг агаарын мэдээлэл авахад алдаа гарлаа';
    } catch (_) {
      throw 'Цаг агаарын мэдээлэл боловсруулахад алдаа гарлаа';
    }
  }

  Future<List<City>> searchCities(String query) async {
    final trimmedQuery = query.trim();

    if (trimmedQuery.length < 2) {
      return [];
    }

    try {
      final response = await _dio.get(
        '/search.json',
        queryParameters: {
          'key': _apiKey,
          'q': trimmedQuery,
        },
      );

      final data = response.data as List<dynamic>;

      return data
          .map((item) => City.fromJson(item as Map<String, dynamic>))
          .toList();
    } on DioException catch (_) {
      return [];
    } catch (_) {
      return [];
    }
  }
}
