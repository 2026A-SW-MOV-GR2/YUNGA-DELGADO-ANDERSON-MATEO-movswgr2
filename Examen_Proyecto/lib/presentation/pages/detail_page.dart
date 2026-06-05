// lib/presentation/pages/detail/detail_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/theme/app_theme.dart';
import '../../domain/entities/content_item.dart';
import '../providers/content_provider.dart';
import 'add_edit_page.dart';

class DetailPage extends StatelessWidget {
  final ContentItem item;
  const DetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 340,
            pinned: true,
            backgroundColor: AppColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (item.posterUrl.isNotEmpty && item.posterUrl.startsWith('http'))
                    CachedNetworkImage(
                      imageUrl: item.posterUrl,
                      fit: BoxFit.cover,
                      placeholder: (context, url) => Container(
                        color: AppColors.surface,
                        child: const Center(child: CircularProgressIndicator()),
                      ),
                      errorWidget: (context, url, error) => _fallbackPoster(),
                    )
                  else
                    _fallbackPoster(),
                  // Gradient overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, AppColors.background],
                        stops: [0.4, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(
                  item.isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: item.isFavorite ? AppColors.primary : AppColors.white,
                ),
                onPressed: () {
                  context.read<ContentProvider>().toggleFavorite(item);
                  Navigator.pop(context);
                },
              ),
              IconButton(
                icon: const Icon(Icons.edit, color: AppColors.white),
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => AddEditPage(item: item)),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: Colors.redAccent),
                onPressed: () => _confirmDelete(context),
              ),
            ],
          ),
          // Content
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title + year
                  Text(item.title, style: const TextStyle(
                    color: AppColors.white, fontSize: 26, fontWeight: FontWeight.w800)),
                  const SizedBox(height: 6),
                  Row(children: [
                    _Tag(item.year.toString()),
                    const SizedBox(width: 8),
                    _Tag(item.genre),
                    const SizedBox(width: 8),
                    _Tag(item.isMovie ? '🎬 Película' : '📺 Serie'),
                  ]),
                  const SizedBox(height: 12),
                  // Status badge
                  _StatusRow(item: item),
                  const SizedBox(height: 16),
                  // Stars
                  if (item.rating > 0) _RatingRow(rating: item.rating),
                  const SizedBox(height: 16),
                  // Description
                  if (item.description.isNotEmpty) ...[
                    const Text('Descripción', style: TextStyle(
                        color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Text(item.description, style: const TextStyle(color: AppColors.grey, height: 1.5)),
                    const SizedBox(height: 20),
                  ],
                  // Series-specific
                  if (item.isSeries && (item.currentSeason != null || item.currentEpisode != null)) ...[
                    const Text('Progreso', style: TextStyle(
                        color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Row(children: [
                      if (item.currentSeason != null)
                        _Tag('Temporada ${item.currentSeason}'),
                      if (item.currentEpisode != null) ...[
                        const SizedBox(width: 8),
                        _Tag('Episodio ${item.currentEpisode}'),
                      ],
                    ]),
                    const SizedBox(height: 20),
                  ],
                  // Comment
                  if (item.comment.isNotEmpty) ...[
                    const Text('Comentario Personal', style: TextStyle(
                        color: AppColors.white, fontSize: 16, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.greyDark),
                      ),
                      child: Text(
                        '"${item.comment}"',
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontStyle: FontStyle.italic,
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Eliminar', style: TextStyle(color: AppColors.white)),
        content: Text(
          '¿Eliminar "${item.title}" de tu biblioteca?',
          style: const TextStyle(color: AppColors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar', style: TextStyle(color: AppColors.grey)),
          ),
          TextButton(
            onPressed: () {
              context.read<ContentProvider>().deleteItem(item.id);
              Navigator.pop(context); // close dialog
              Navigator.pop(context); // close detail
            },
            child: const Text('Eliminar', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _fallbackPoster() {
    return Image.asset(
      'assets/images/default-movie.png',
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.surface,
        child: const Center(child: Icon(Icons.movie, color: AppColors.greyDark, size: 80)),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String text;
  const _Tag(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(text, style: const TextStyle(color: AppColors.grey, fontSize: 12)),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final ContentItem item;
  const _StatusRow({required this.item});

  @override
  Widget build(BuildContext context) {
    Color color;
    IconData icon;
    switch (item.status) {
      case WatchStatus.pending:
        color = Colors.orange;
        icon = Icons.hourglass_empty;
        break;
      case WatchStatus.watching:
        color = Colors.blue;
        icon = Icons.play_circle_outline;
        break;
      case WatchStatus.completed:
        color = Colors.green;
        icon = Icons.check_circle_outline;
        break;
    }
    return Row(children: [
      Icon(icon, color: color, size: 18),
      const SizedBox(width: 6),
      Text(item.statusLabel, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
    ]);
  }
}

class _RatingRow extends StatelessWidget {
  final double rating;
  const _RatingRow({required this.rating});

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      ...List.generate(5, (i) {
        if (i < rating.floor()) {
          return const Icon(Icons.star, color: AppColors.star, size: 22);
        } else if (i < rating) {
          return const Icon(Icons.star_half, color: AppColors.star, size: 22);
        }
        return const Icon(Icons.star_border, color: AppColors.greyDark, size: 22);
      }),
      const SizedBox(width: 8),
      Text(
        rating.toStringAsFixed(1),
        style: const TextStyle(color: AppColors.star, fontWeight: FontWeight.w700, fontSize: 16),
      ),
    ]);
  }
}
