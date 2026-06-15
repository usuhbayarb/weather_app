
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_providers.dart';
import '../theme/app_theme.dart';
import '../screens/weather_detail_screen.dart';

class MostViewedSection extends ConsumerWidget {
  const MostViewedSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mvAsync = ref.watch(mostViewedProvider);

    return mvAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (cities) {
        if (cities.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.history, color: AppTheme.accent, size: 18),
                  const SizedBox(width: 8),
                  const Text(
                    'Сүүлд үзсэн',
                    style: TextStyle(
                        color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: cities
                    .take(6)
                    .map(
                      (c) => ActionChip(
                        backgroundColor: AppTheme.cardDark,
                        side: const BorderSide(color: Colors.white12),
                        label: Text(
                          '${c.name}, ${c.country}',
                          style: const TextStyle(color: Colors.white, fontSize: 12),
                        ),
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => WeatherDetailScreen(city: c)),
                        ),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }
}
