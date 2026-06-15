
import 'package:dio/dio.dart';
import '../models/weather_model.dart';

class WeatherService {
  static const String _baseUrl = 'https://api.weatherapi.com/v1';

  // API key-г build үед --dart-define ашиглан сольж болно:
  // flutter run --dart-define=WEATHER_API_KEY=your_key
  static const String _apiKey = String.fromEnvironment(
    'WEATHER_API_KEY',
    defaultValue: 'cb288425569c4c8db0164139261106',
  );

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
      final response = await _dio.get('/forecast.json', queryParameters: {
        'key': _apiKey,
        'q': query,
        'days': 7,
        'aqi': 'no',
        'alerts': 'no',
        'lang': 'mn',
      });

      final data = response.data;
      return WeatherData.fromJson(
        data['current'],
        data['location'],
        data['forecast']['forecastday'],
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<City>> searchCities(String query) async {
    if (query.trim().length < 2) return [];
    try {
      final response = await _dio.get('/search.json', queryParameters: {
        'key': _apiKey,
        'q': query.trim(),
      });
      return (response.data as List).map((c) => City.fromJson(c)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(DioException e) {
    final statusCode = e.response?.statusCode;
    String? errorMessage;
    final responseData = e.response?.data;

    if (responseData is Map) {
      final error = responseData['error'];
      if (error is Map && error['message'] != null) {
        errorMessage = error['message'].toString();
      }
    }

    if (statusCode == 401 || statusCode == 403) {
      return 'API түлхүүр буруу эсвэл идэвхгүй байна';
    }
    if (statusCode == 400) {
      return errorMessage ?? 'Хот олдсонгүй';
    }
    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return 'Холболт удаан байна';
    }
    if (e.type == DioExceptionType.connectionError) {
      return 'Интернет холболтоо шалгана уу';
    }
    return errorMessage ?? 'Алдаа гарлаа: ${e.message}';
  }
}
