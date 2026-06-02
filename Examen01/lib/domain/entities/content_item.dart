// lib/domain/entities/content_item.dart

enum ContentType { movie, series }

enum WatchStatus { pending, watching, completed }

class ContentItem {
  final String id;
  final String title;
  final int year;
  final String genre;
  final String description;
  final String posterUrl;
  final ContentType type;
  final WatchStatus status;
  final DateTime? watchedDate;
  final double rating; // 0.0 - 5.0
  final String comment;
  final bool isFavorite;
  // Solo para series
  final int? currentSeason;
  final int? currentEpisode;

  const ContentItem({
    required this.id,
    required this.title,
    required this.year,
    required this.genre,
    required this.description,
    required this.posterUrl,
    required this.type,
    required this.status,
    this.watchedDate,
    this.rating = 0.0,
    this.comment = '',
    this.isFavorite = false,
    this.currentSeason,
    this.currentEpisode,
  });

  ContentItem copyWith({
    String? id,
    String? title,
    int? year,
    String? genre,
    String? description,
    String? posterUrl,
    ContentType? type,
    WatchStatus? status,
    DateTime? watchedDate,
    double? rating,
    String? comment,
    bool? isFavorite,
    int? currentSeason,
    int? currentEpisode,
  }) {
    return ContentItem(
      id: id ?? this.id,
      title: title ?? this.title,
      year: year ?? this.year,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      posterUrl: posterUrl ?? this.posterUrl,
      type: type ?? this.type,
      status: status ?? this.status,
      watchedDate: watchedDate ?? this.watchedDate,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      isFavorite: isFavorite ?? this.isFavorite,
      currentSeason: currentSeason ?? this.currentSeason,
      currentEpisode: currentEpisode ?? this.currentEpisode,
    );
  }

  bool get isMovie => type == ContentType.movie;
  bool get isSeries => type == ContentType.series;

  String get statusLabel {
    switch (status) {
      case WatchStatus.pending: return 'Pendiente';
      case WatchStatus.watching: return 'Viendo';
      case WatchStatus.completed: return 'Completada';
    }
  }
}
