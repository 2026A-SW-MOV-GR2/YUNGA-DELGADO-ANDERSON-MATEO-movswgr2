// lib/data/models/content_model.dart
import '../../domain/entities/content_item.dart';

class ContentModel extends ContentItem {
  const ContentModel({
    required super.id,
    required super.title,
    required super.year,
    required super.genre,
    required super.description,
    required super.posterUrl,
    required super.type,
    required super.status,
    super.watchedDate,
    super.rating,
    super.comment,
    super.isFavorite,
    super.currentSeason,
    super.currentEpisode,
  });

  // ── SQL (Map) ──────────────────────────────────────────────
  factory ContentModel.fromMap(Map<String, dynamic> map) {
    return ContentModel(
      id: map['id'] as String,
      title: map['title'] as String,
      year: map['year'] as int,
      genre: map['genre'] as String,
      description: map['description'] as String,
      posterUrl: map['posterUrl'] as String,
      type: ContentType.values[map['type'] as int],
      status: WatchStatus.values[map['status'] as int],
      watchedDate: map['watchedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['watchedDate'] as int)
          : null,
      rating: (map['rating'] as num).toDouble(),
      comment: map['comment'] as String? ?? '',
      isFavorite: (map['isFavorite'] as int) == 1,
      currentSeason: map['currentSeason'] as int?,
      currentEpisode: map['currentEpisode'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'genre': genre,
      'description': description,
      'posterUrl': posterUrl,
      'type': type.index,
      'status': status.index,
      'watchedDate': watchedDate?.millisecondsSinceEpoch,
      'rating': rating,
      'comment': comment,
      'isFavorite': isFavorite ? 1 : 0,
      'currentSeason': currentSeason,
      'currentEpisode': currentEpisode,
    };
  }

  // ── NoSQL (JSON-like Map) ─────────────────────────────────
  factory ContentModel.fromJson(Map<dynamic, dynamic> json) {
    return ContentModel(
      id: json['id'] as String,
      title: json['title'] as String,
      year: json['year'] as int,
      genre: json['genre'] as String,
      description: json['description'] as String,
      posterUrl: json['posterUrl'] as String,
      type: ContentType.values[json['type'] as int],
      status: WatchStatus.values[json['status'] as int],
      watchedDate: json['watchedDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['watchedDate'] as int)
          : null,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String? ?? '',
      isFavorite: json['isFavorite'] as bool,
      currentSeason: json['currentSeason'] as int?,
      currentEpisode: json['currentEpisode'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'year': year,
      'genre': genre,
      'description': description,
      'posterUrl': posterUrl,
      'type': type.index,
      'status': status.index,
      'watchedDate': watchedDate?.millisecondsSinceEpoch,
      'rating': rating,
      'comment': comment,
      'isFavorite': isFavorite,
      'currentSeason': currentSeason,
      'currentEpisode': currentEpisode,
    };
  }

  factory ContentModel.fromEntity(ContentItem item) {
    return ContentModel(
      id: item.id,
      title: item.title,
      year: item.year,
      genre: item.genre,
      description: item.description,
      posterUrl: item.posterUrl,
      type: item.type,
      status: item.status,
      watchedDate: item.watchedDate,
      rating: item.rating,
      comment: item.comment,
      isFavorite: item.isFavorite,
      currentSeason: item.currentSeason,
      currentEpisode: item.currentEpisode,
    );
  }
}
