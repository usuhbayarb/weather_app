
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_providers.dart';
import '../models/weather_model.dart';
import '../theme/app_theme.dart';
import '../screens/weather_detail_screen.dart';

class CountrySection extends ConsumerWidget {
  const CountrySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countries = ref.watch(countriesProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _SectionHeader(title: 'Улс орнууд', icon: Icons.public),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: countries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _CountryTile(country: countries[i]),
          ),
        ],
      ),
    );
  }
}

class _CountryTile extends ConsumerWidget {
  final Map<String, String> country;
  const _CountryTile({required this.country});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = country['query']!;
    final weatherAsync = ref.watch(weatherProvider(query));

    return GestureDetector(
      onTap: () {
        final weather = weatherAsync.valueOrNull;
        if (weather == null) return;
        final city = City(
          name: weather.cityName,
          country: weather.country,
          lat: weather.lat,
          lon: weather.lon,
        );
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => WeatherDetailScreen(city: city)),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: AppTheme.cardDark,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0x14FFFFFF)),
        ),
        child: Row(
          children: [
            // Flag & name
            Text(country['flag']!, style: const TextStyle(fontSize: 28)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(country['name']!,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                  weatherAsync.when(
                    loading: () => Text('Ачааллаж байна...',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                    error: (_, __) => Text('Алдаа гарлаа',
                        style: TextStyle(color: Colors.redAccent.withOpacity(.7), fontSize: 12)),
                    data: (w) => Text(w.description,
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  ),
                ],
              ),
            ),
            // Temp
            weatherAsync.when(
              loading: () => const SizedBox(
                width: 20, height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.skyBlue),
              ),
              error: (_, __) => const Icon(Icons.error_outline, color: Colors.red, size: 20),
              data: (w) => Text(
                '${w.tempC.round()}°C',
                style: const TextStyle(
                    color: Colors.white, fontSize: 20, fontWeight: FontWeight.w300),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _SectionHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.skyBlue, size: 18),
        const SizedBox(width: 8),
        Text(title,
            style: const TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
      ],
    );
  }
}
