// lib/presentation/pages/library/library_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/content_item.dart';
import '../providers/content_provider.dart';
import '../widgets/content_card.dart';
import '../widgets/engine_switch_widget.dart';
import 'detail_page.dart';
import 'add_edit_page.dart';

enum _LibraryFilter { all, movies, series, watched, pending, favorites }

class LibraryPage extends StatefulWidget {
  const LibraryPage({super.key});

  @override
  State<LibraryPage> createState() => _LibraryPageState();
}

class _LibraryPageState extends State<LibraryPage> {
  _LibraryFilter _filter = _LibraryFilter.all;

  List<ContentItem> _applyFilter(ContentProvider provider) {
    switch (_filter) {
      case _LibraryFilter.all:
        return provider.items;
      case _LibraryFilter.movies:
        return provider.movies;
      case _LibraryFilter.series:
        return provider.series;
      case _LibraryFilter.watched:
        return provider.watched;
      case _LibraryFilter.pending:
        return provider.pending;
      case _LibraryFilter.favorites:
        return provider.favorites;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Biblioteca'),
        actions: const [EngineSwitchWidget()],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.primary,
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const AddEditPage()),
        ),
        child: const Icon(Icons.add, color: AppColors.white),
      ),
      body: Consumer<ContentProvider>(
        builder: (context, provider, _) {
          final filtered = _applyFilter(provider);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Filter chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: _LibraryFilter.values.map((f) {
                    final selected = _filter == f;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(_filterLabel(f)),
                        selected: selected,
                        onSelected: (_) => setState(() => _filter = f),
                      ),
                    );
                  }).toList(),
                ),
              ),
              // Count
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Text(
                  '${filtered.length} resultado${filtered.length != 1 ? 's' : ''}',
                  style: const TextStyle(color: AppColors.grey, fontSize: 13),
                ),
              ),
              // Grid
              Expanded(
                child: provider.isLoading
                    ? const Center(child: CircularProgressIndicator(color: AppColors.primary))
                    : filtered.isEmpty
                        ? const Center(
                            child: Text(
                              'Sin resultados',
                              style: TextStyle(color: AppColors.grey),
                            ),
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.52,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, index) {
                              final item = filtered[index];
                              return ContentCard(
                                item: item,
                                onTap: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (_) => DetailPage(item: item)),
                                ),
                                onFavoriteToggle: () =>
                                    provider.toggleFavorite(item),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _filterLabel(_LibraryFilter f) {
    switch (f) {
      case _LibraryFilter.all: return 'Todas';
      case _LibraryFilter.movies: return '🎬 Películas';
      case _LibraryFilter.series: return '📺 Series';
      case _LibraryFilter.watched: return '✅ Vistas';
      case _LibraryFilter.pending: return '⏳ Pendientes';
      case _LibraryFilter.favorites: return '❤️ Favoritas';
    }
  }
}
