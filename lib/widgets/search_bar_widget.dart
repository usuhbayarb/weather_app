
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/weather_providers.dart';
import '../theme/app_theme.dart';
import '../models/weather_model.dart';
import '../screens/weather_detail_screen.dart';

class SearchBarWidget extends ConsumerStatefulWidget {
  const SearchBarWidget({super.key});

  @override
  ConsumerState<SearchBarWidget> createState() => _SearchBarWidgetState();
}

class _SearchBarWidgetState extends ConsumerState<SearchBarWidget> {
  final _controller = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    ref.read(searchQueryProvider.notifier).state = value;
  }

  void _clearSearch() {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    _focusNode.requestFocus();
  }

  void _selectCity(City city) {
    _controller.clear();
    ref.read(searchQueryProvider.notifier).state = '';
    _focusNode.unfocus();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => WeatherDetailScreen(city: city)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = ref.watch(searchQueryProvider);
    final showResults = ref.watch(searchResultsVisibleProvider);
    final results = ref.watch(searchResultsProvider);

    return Column(
      children: [
        // Search field
        Container(
          decoration: BoxDecoration(
            color: AppTheme.cardDark,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white12),
          ),
          child: TextField(
            controller: _controller,
            focusNode: _focusNode,
            onChanged: _onChanged,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Хот хайх...',
              hintStyle: TextStyle(color: AppTheme.textSecondary),
              prefixIcon: Icon(Icons.search, color: AppTheme.textSecondary),
              suffixIcon: query.isNotEmpty
                  ? IconButton(
                      icon: Icon(Icons.clear, color: AppTheme.textSecondary),
                      onPressed: _clearSearch,
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
            ),
          ),
        ),

        // Results dropdown
        if (showResults)
          Container(
            margin: const EdgeInsets.only(top: 4),
            decoration: BoxDecoration(
              color: AppTheme.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white12),
            ),
            child: results.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.skyBlue)),
              ),
              error: (e, _) => Padding(
                padding: const EdgeInsets.all(16),
                child: Text(e.toString(), style: const TextStyle(color: Colors.white70)),
              ),
              data: (cities) => cities.isEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text('Хот олдсонгүй', style: TextStyle(color: AppTheme.textSecondary)),
                    )
                  : ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: cities.length,
                      separatorBuilder: (_, __) => Divider(color: Colors.white10, height: 1),
                      itemBuilder: (_, i) {
                        final city = cities[i];
                        return ListTile(
                          leading: Icon(Icons.location_on, color: AppTheme.skyBlue, size: 20),
                          title: Text(city.name, style: const TextStyle(color: Colors.white)),
                          subtitle: Text(city.country, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                          onTap: () => _selectCity(city),
                        );
                      },
                    ),
            ),
          ),
      ],
    );
  }
}
