// lib/widgets/favorites_section.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_providers.dart';
import '../theme/app_theme.dart';
import '../screens/weather_detail_screen.dart';
import 'package:cached_network_image/cached_network_image.dart';

class FavoritesSection extends ConsumerWidget {
  const FavoritesSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesProvider);

    return favAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (favorites) {
        if (favorites.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Дуртай хотууд',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: favorites.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (_, i) => _FavCard(city: favorites[i]),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _FavCard extends ConsumerWidget {
  final city;
  const _FavCard({required this.city});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = '${city.lat},${city.lon}';
    final weatherAsync = ref.watch(weatherProvider(query));

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => WeatherDetailScreen(city: city)),
      ),
      child: Container(
        width: 130,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.cardMid, AppTheme.cardDark],
          ),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.favorite, color: Colors.redAccent, size: 12),
                const Spacer(),
                weatherAsync.when(
                  loading: () => const SizedBox(width: 28, height: 28),
                  error: (_, __) => const SizedBox.shrink(),
                  data: (w) => CachedNetworkImage(width: 28, height: 28, imageUrl: w.icon),
                ),
              ],
            ),
            const Spacer(),
            Text(
              city.name,
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(city.country,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
            const SizedBox(height: 4),
            weatherAsync.when(
              loading: () => Text('...', style: TextStyle(color: AppTheme.skyBlue, fontSize: 20)),
              error: (_, __) => const Icon(Icons.error_outline, color: Colors.red, size: 18),
              data: (w) => Text(
                '${w.tempC.round()}°C',
                style: const TextStyle(
                    color: Colors.white, fontSize: 22, fontWeight: FontWeight.w200),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
