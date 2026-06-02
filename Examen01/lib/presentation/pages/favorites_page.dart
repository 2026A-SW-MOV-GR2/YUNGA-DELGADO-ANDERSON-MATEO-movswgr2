// lib/presentation/pages/favorites/favorites_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/content_provider.dart';
import '../widgets/content_card.dart';
import '../widgets/engine_switch_widget.dart';
import 'detail_page.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favoritos'),
        actions: const [EngineSwitchWidget()],
      ),
      body: Consumer<ContentProvider>(
        builder: (context, provider, _) {
          final favorites = provider.favorites;
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          }
          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.favorite_border, color: AppColors.greyDark, size: 72),
                  SizedBox(height: 16),
                  Text(
                    'Sin favoritos aún',
                    style: TextStyle(color: AppColors.white, fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Marca tus películas y series\npreferidas con ❤️',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.grey, fontSize: 14),
                  ),
                ],
              ),
            );
          }
          return GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.52,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final item = favorites[index];
              return ContentCard(
                item: item,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => DetailPage(item: item)),
                ),
                onFavoriteToggle: () => provider.toggleFavorite(item),
              );
            },
          );
        },
      ),
    );
  }
}
