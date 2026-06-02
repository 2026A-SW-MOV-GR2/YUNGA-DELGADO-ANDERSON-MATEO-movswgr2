// lib/domain/repositories/content_repository.dart
import '../entities/content_item.dart';

/// Contrato abstracto del Patrón Repositorio.
/// La UI nunca accede directamente al motor SQL o NoSQL.
abstract class ContentRepository {
  Future<List<ContentItem>> getAll();
  Future<ContentItem?> getById(String id);
  Future<void> save(ContentItem item);
  Future<void> update(ContentItem item);
  Future<void> delete(String id);
  Future<List<ContentItem>> getByType(ContentType type);
  Future<List<ContentItem>> getByStatus(WatchStatus status);
  Future<List<ContentItem>> getFavorites();
  Future<List<ContentItem>> getRecent({int limit = 10});
}
