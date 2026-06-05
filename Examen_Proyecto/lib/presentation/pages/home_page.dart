// lib/presentation/pages/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/entities/content_item.dart';
import '../providers/content_provider.dart';
import '../widgets/content_card.dart';
import '../widgets/engine_switch_widget.dart';
import 'detail_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String _selectedFilter = 'Todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<ContentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }

          final featuredItem = provider.items.isNotEmpty ? provider.items.last : null;
          final watchingItems = provider.items.where((e) => e.status == WatchStatus.watching).toList();
          
          // Filtrado para la sección principal para evitar repeticiones excesivas
          List<ContentItem> filteredItems;
          switch (_selectedFilter) {
            case 'Películas':
              filteredItems = provider.movies;
              break;
            case 'Series':
              filteredItems = provider.series;
              break;
            case 'Favoritos':
              filteredItems = provider.favorites;
              break;
            default:
              filteredItems = provider.items.reversed.toList();
          }

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: provider.loadAll,
            child: CustomScrollView(
              slivers: [
                // AppBar transparente que se integra con el Hero
                SliverAppBar(
                  floating: true,
                  backgroundColor: Colors.transparent,
                  elevation: 0,
                  title: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(text: 'Cine', style: TextStyle(color: AppColors.white, fontSize: 22, fontWeight: FontWeight.w900)),
                        TextSpan(text: 'Track', style: TextStyle(color: AppColors.primary, fontSize: 22, fontWeight: FontWeight.w900)),
                      ],
                    ),
                  ),
                  actions: const [EngineSwitchWidget(), SizedBox(width: 8)],
                ),

                // 1. Hero / Destacado (El último añadido)
                if (featuredItem != null)
                  SliverToBoxAdapter(
                    child: _FeaturedHero(item: featuredItem),
                  ),

                // 2. Stats Rápidas
                SliverToBoxAdapter(
                  child: _QuickStats(provider: provider),
                ),

                // 3. Continuar Viendo (Solo si hay ítems en estado 'Watching')
                if (watchingItems.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _SectionHeader(title: 'Continuar Viendo'),
                        _HorizontalList(items: watchingItems),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),

                // 4. Selector de Categoría (Evita tener mil listas horizontales)
                SliverToBoxAdapter(
                  child: _CategorySelector(
                    selected: _selectedFilter,
                    onSelected: (val) => setState(() => _selectedFilter = val),
                  ),
                ),

                // 5. Grid Principal (Contenido dinámico según el filtro)
                if (filteredItems.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.7,
                        mainAxisSpacing: 16,
                        crossAxisSpacing: 16,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => ContentCard(
                          item: filteredItems[index],
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => DetailPage(item: filteredItems[index])),
                          ),
                          onFavoriteToggle: () => provider.toggleFavorite(filteredItems[index]),
                        ),
                        childCount: filteredItems.length > 6 ? 6 : filteredItems.length, // Mostrar pocos en el home
                      ),
                    ),
                  ),

                if (provider.items.isEmpty)
                  SliverFillRemaining(
                    child: _EmptyState(),
                  ),

                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _FeaturedHero extends StatelessWidget {
  final ContentItem item;
  const _FeaturedHero({required this.item});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => DetailPage(item: item))),
      child: Container(
        height: 400,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: DecorationImage(
            image: (item.posterUrl.isNotEmpty && item.posterUrl.startsWith('http'))
                ? CachedNetworkImageProvider(item.posterUrl) as ImageProvider
                : const AssetImage('assets/images/default-movie.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Colors.black.withOpacity(0.8)],
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(4)),
                child: const Text('RECIÉN AGREGADO', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              Text(item.title, style: const TextStyle(color: Colors.white, fontSize: 28, fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text('${item.year} • ${item.genre} • ${item.isMovie ? "Película" : "Serie"}', 
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
            ],
          ),
        ),
      ),
    );
  }
}

class _QuickStats extends StatelessWidget {
  final ContentProvider provider;
  const _QuickStats({required this.provider});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _StatItem(label: 'Total', value: provider.items.length),
          _StatItem(label: 'Vistas', value: provider.watched.length),
          _StatItem(label: 'Favoritas', value: provider.favorites.length),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final int value;
  const _StatItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value.toString(), style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
        Text(label, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      ],
    );
  }
}

class _CategorySelector extends StatelessWidget {
  final String selected;
  final Function(String) onSelected;
  const _CategorySelector({required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    final filters = ['Todos', 'Películas', 'Series', 'Favoritos'];
    return SizedBox(
      height: 60,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final isSelected = selected == filters[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filters[index]),
              selected: isSelected,
              onSelected: (_) => onSelected(filters[index]),
              selectedColor: AppColors.primary,
              backgroundColor: AppColors.surface,
              labelStyle: TextStyle(color: isSelected ? Colors.white : AppColors.grey),
            ),
          );
        },
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(title, style: const TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.bold)),
    );
  }
}

class _HorizontalList extends StatelessWidget {
  final List<ContentItem> items;
  const _HorizontalList({required this.items});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          return Container(
            width: 140,
            margin: const EdgeInsets.only(right: 12),
            child: ContentCard(
              item: items[index],
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DetailPage(item: items[index])),
              ),
              onFavoriteToggle: () => context.read<ContentProvider>().toggleFavorite(items[index]),
            ),
          );
        },
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.movie_creation_outlined, color: AppColors.greyDark, size: 64),
          SizedBox(height: 16),
          Text('Nada por aquí todavía', style: TextStyle(color: AppColors.white, fontSize: 18)),
        ],
      ),
    );
  }
}
