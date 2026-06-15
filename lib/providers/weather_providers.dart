
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

//  Service provider
final weatherServiceProvider = Provider<WeatherService>((ref) => WeatherService());

// Favourites
final favoritesProvider = AsyncNotifierProvider<FavoritesNotifier, List<City>>(
  FavoritesNotifier.new,
);

class FavoritesNotifier extends AsyncNotifier<List<City>> {
  static const _key = 'favorite_cities';

  @override
  Future<List<City>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => City.fromJson(jsonDecode(s))).toList();
  }

  Future<void> toggle(City city) async {
    final current = await future;
    final exists = current.any((c) => c.name == city.name && c.country == city.country);
    final updated = exists
        ? current.where((c) => !(c.name == city.name && c.country == city.country)).toList()
        : [...current, city];
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated.map((c) => jsonEncode(c.toJson())).toList());
  }

  Future<bool> isFavorite(City city) async {
    final current = await future;
    return current.any((c) => c.name == city.name && c.country == city.country);
  }
}

//  Most viewed
final mostViewedProvider = AsyncNotifierProvider<MostViewedNotifier, List<City>>(
  MostViewedNotifier.new,
);

class MostViewedNotifier extends AsyncNotifier<List<City>> {
  static const _key = 'most_viewed';

  @override
  Future<List<City>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_key) ?? [];
    return raw.map((s) => City.fromJson(jsonDecode(s))).toList();
  }

  Future<void> recordView(City city) async {
    final current = await future;
    final filtered = current.where((c) => !(c.name == city.name && c.country == city.country)).toList();
    final updated = [city, ...filtered].take(10).toList();
    state = AsyncData(updated);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, updated.map((c) => jsonEncode(c.toJson())).toList());
  }
}

//  Popular countries list
final countriesProvider = Provider<List<Map<String, String>>>((ref) {
  return [
    {'name': 'Монгол', 'query': 'Ulaanbaatar', 'flag': '🇲🇳'},
    {'name': 'Япон', 'query': 'Tokyo', 'flag': '🇯🇵'},
    {'name': 'Хятад', 'query': 'Beijing', 'flag': '🇨🇳'},
    {'name': 'Солонгос', 'query': 'Seoul', 'flag': '🇰🇷'},
    {'name': 'АНУ', 'query': 'New York', 'flag': '🇺🇸'},
    {'name': 'Герман', 'query': 'Berlin', 'flag': '🇩🇪'},
    {'name': 'Франц', 'query': 'Paris', 'flag': '🇫🇷'},
    {'name': 'Их Британи', 'query': 'London', 'flag': '🇬🇧'},
    {'name': 'Австрали', 'query': 'Sydney', 'flag': '🇦🇺'},
    {'name': 'Орос', 'query': 'Moscow', 'flag': '🇷🇺'},
  ];
});

//  Single weather fetch
final weatherProvider = FutureProvider.family<WeatherData, String>((ref, query) async {
  return ref.read(weatherServiceProvider).getWeather(query);
});

// Search
final searchQueryProvider = StateProvider<String>((ref) => '');

final searchResultsVisibleProvider = Provider<bool>((ref) {
  final query = ref.watch(searchQueryProvider).trim();
  return query.length >= 2;
});

final searchResultsProvider = FutureProvider<List<City>>((ref) async {
  final query = ref.watch(searchQueryProvider).trim();
  if (query.length < 2) return [];
  return ref.read(weatherServiceProvider).searchCities(query);
});
