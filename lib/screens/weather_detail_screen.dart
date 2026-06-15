import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/weather_model.dart';
import '../providers/weather_providers.dart';
import '../theme/app_theme.dart';

class WeatherDetailScreen extends ConsumerWidget {
  final City city;
  const WeatherDetailScreen({super.key, required this.city});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = '${city.lat},${city.lon}';
    final weatherAsync = ref.watch(weatherProvider(query));

    // Record view on first build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(mostViewedProvider.notifier).recordView(city);
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.bgGradient),
        child: SafeArea(
          child: weatherAsync.when(
            loading: () => const Center(child: CircularProgressIndicator(color: AppTheme.skyBlue)),
            error: (e, _) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: AppTheme.accent, size: 48),
                  const SizedBox(height: 12),
                  Text(e.toString(), style: const TextStyle(color: Colors.white)),
                  TextButton(
                    onPressed: () => ref.invalidate(weatherProvider(query)),
                    child: const Text('Дахин оролдох'),
                  ),
                ],
              ),
            ),
            data: (weather) => _WeatherContent(city: city, weather: weather),
          ),
        ),
      ),
    );
  }
}

class _WeatherContent extends ConsumerWidget {
  final City city;
  final WeatherData weather;
  const _WeatherContent({required this.city, required this.weather});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favAsync = ref.watch(favoritesProvider);
    final isFav = favAsync.valueOrNull?.any(
          (c) => c.name == city.name && c.country == city.country,
        ) ?? false;

    return CustomScrollView(
      slivers: [
        //  App Bar
        SliverAppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [
            IconButton(
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 300),
                child: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  key: ValueKey(isFav),
                  color: isFav ? Colors.redAccent : Colors.white,
                ),
              ),
              onPressed: () => ref.read(favoritesProvider.notifier).toggle(city),
            ),
          ],
          pinned: false,
        ),

        // Main temp card
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: [
                // City name
                Text(
                  weather.cityName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  weather.country,
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                ),
                const SizedBox(height: 12),

                // Weather icon
                CachedNetworkImage(width: 96, height: 96, imageUrl: weather.icon),

                // Temperature
                Text(
                  '${weather.tempC.round()}°C',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 80,
                    fontWeight: FontWeight.w200,
                    height: 1,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  weather.description,
                  style: const TextStyle(color: Colors.white70, fontSize: 18),
                ),
                const SizedBox(height: 4),
                Text(
                  'Мэдрэмж ${weather.feelsLike.round()}°C',
                  style: TextStyle(color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),

        //  Stats row
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _StatsRow(weather: weather),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        //  7-day forecast
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _ForecastCard(daily: weather.daily, cityName: weather.cityName),
          ),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 30)),
      ],
    );
  }
}

class _StatsRow extends StatelessWidget {
  final WeatherData weather;
  const _StatsRow({required this.weather});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(icon: Icons.water_drop, label: 'Чийгшил', value: '${weather.humidity}%'),
          _Divider(),
          _StatItem(icon: Icons.air, label: 'Салхи', value: '${weather.windSpeed.round()} км/ц'),
          _Divider(),
          _StatItem(icon: Icons.visibility, label: 'Харалт', value: '${weather.visibility} км'),
          _Divider(),
          _StatItem(icon: Icons.compress, label: 'Даралт', value: '${weather.pressure}'),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) =>
      Container(height: 40, width: 1, color: Colors.white12);
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: AppTheme.skyBlue, size: 22),
        const SizedBox(height: 6),
        Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
      ],
    );
  }
}

class _ForecastCard extends StatelessWidget {
  final List<DailyForecast> daily;
  final String cityName;
  const _ForecastCard({required this.daily, required this.cityName});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardDark,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_today, size: 16, color: AppTheme.textSecondary),
              const SizedBox(width: 6),
              Text(
                '7 ХОНОГИЙН ТААМАГ',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...daily.map(
                (d) => _ForecastRow(
              day: d,
              onTap: () => showModalBottomSheet(
                context: context,
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
                builder: (_) => _DayDetailSheet(day: d, cityName: cityName),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ForecastRow extends StatelessWidget {
  final DailyForecast day;
  final VoidCallback onTap;
  const _ForecastRow({required this.day, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isToday = day.date.day == DateTime.now().day;
    final dayLabel = isToday
        ? 'Өнөөдөр'
        : DateFormat('E', 'mn').format(day.date); // Mon, Tue

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 80,
              child: Text(
                dayLabel,
                style: TextStyle(
                  color: isToday ? AppTheme.skyBlue : Colors.white,
                  fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ),
            CachedNetworkImage(width: 32, height: 32, imageUrl: day.icon),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                day.description,
                style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (day.chanceOfRain > 0)
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Text(
                  ' ${day.chanceOfRain}%',
                  style: TextStyle(color: AppTheme.skyBlue, fontSize: 12),
                ),
              ),
            Text(
              '${day.maxTemp.round()}°',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
            const SizedBox(width: 6),
            Text(
              '${day.minTemp.round()}°',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right, size: 16, color: Colors.white24),
          ],
        ),
      ),
    );
  }
}

class _DayDetailSheet extends StatelessWidget {
  final DailyForecast day;
  final String cityName;
  const _DayDetailSheet({required this.day, required this.cityName});

  @override
  Widget build(BuildContext context) {
    final isToday = day.date.day == DateTime.now().day;
    final dateLabel = isToday ? 'Өнөөдөр' : DateFormat('EEEE, MMM d', 'mn').format(day.date);

    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0D1B2A),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(dateLabel, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  Text(cityName, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                ],
              ),
              const Spacer(),
              CachedNetworkImage(width: 64, height: 64, imageUrl: day.icon),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _TempBadge(label: 'Дээд', temp: day.maxTemp, color: const Color(0xFFFF6B6B)),
              const SizedBox(width: 12),
              _TempBadge(label: 'Доод', temp: day.minTemp, color: const Color(0xFF4FC3F7)),
            ],
          ),
          const SizedBox(height: 8),
          Text(day.description, style: const TextStyle(color: Colors.white70, fontSize: 15)),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF1A2A3A),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(children: [
                  _DetailCell(icon: Icons.water_drop_outlined, label: 'Чийгшил', value: '${day.humidity}%'),
                  _DetailCell(icon: Icons.air, label: 'Салхи', value: '${day.windSpeed.round()} км/ц'),
                ]),
                const Divider(color: Colors.white10, height: 20),
                Row(children: [
                  _DetailCell(icon: Icons.water, label: 'Хур тунадас', value: '${day.totalPrecipMm} мм'),
                  _DetailCell(icon: Icons.umbrella, label: 'Бороо орох', value: '${day.chanceOfRain}%'),
                ]),
                const Divider(color: Colors.white10, height: 20),
                Row(children: [
                  _DetailCell(icon: Icons.visibility_outlined, label: 'Харалт', value: '${day.visibility} км'),
                  _DetailCell(icon: Icons.wb_sunny_outlined, label: 'UV индекс', value: '${day.uvIndex}'),
                ]),
                if (day.chanceOfSnow > 0) ...[
                  const Divider(color: Colors.white10, height: 20),
                  Row(children: [
                    _DetailCell(icon: Icons.ac_unit, label: 'Цас орох', value: '${day.chanceOfSnow}%'),
                  ]),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: Colors.white10,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('Хаах', style: TextStyle(color: Colors.white70, fontSize: 15)),
            ),
          ),
        ],
      ),
    );
  }
}

class _TempBadge extends StatelessWidget {
  final String label;
  final double temp;
  final Color color;
  const _TempBadge({required this.label, required this.temp, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: color.withOpacity(0.8), fontSize: 13)),
          const SizedBox(width: 8),
          Text('${temp.round()}°C', style: TextStyle(color: color, fontSize: 20, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

class _DetailCell extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  const _DetailCell({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4FC3F7), size: 20),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)),
              Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}
