// lib/data/repositories/content_repository_impl.dart
import '../../core/logger/app_logger.dart';
import '../../domain/entities/content_item.dart';
import '../../domain/repositories/content_repository.dart';
import '../datasources/local/nosql_datasource.dart';
import '../datasources/local/sql_datasource.dart';
import '../models/content_model.dart';

/// Implementación del Patrón Repositorio con conmutación dual en tiempo de ejecución.
/// La capa de presentación NO conoce si los datos provienen de SQL o NoSQL.
class ContentRepositoryImpl implements ContentRepository {
  static const _tag = 'ContentRepositoryImpl';

  final SqlDatasource _sqlDs;
  final NoSqlDatasource _noSqlDs;

  /// [useNoSql] controla el motor activo. Se puede cambiar en tiempo de ejecución.
  bool useNoSql;

  ContentRepositoryImpl({
    required SqlDatasource sqlDatasource,
    required NoSqlDatasource noSqlDatasource,
    this.useNoSql = false,
  })  : _sqlDs = sqlDatasource,
        _noSqlDs = noSqlDatasource;

  void switchEngine({required bool toNoSql}) {
    useNoSql = toNoSql;
    AppLogger.info(
      'Motor conmutado → ${useNoSql ? "NoSQL (Hive)" : "SQL (SQLite)"}',
      tag: _tag,
    );
  }

  String get activeEngine => useNoSql ? 'NoSQL' : 'SQL';

  @override
  Future<List<ContentItem>> getAll() async {
    AppLogger.debug('getAll() via $activeEngine', tag: _tag);
    return useNoSql ? _noSqlDs.getAll() : _sqlDs.getAll();
  }

  @override
  Future<ContentItem?> getById(String id) async {
    AppLogger.debug('getById($id) via $activeEngine', tag: _tag);
    return useNoSql ? _noSqlDs.getById(id) : _sqlDs.getById(id);
  }

  @override
  Future<void> save(ContentItem item) async {
    AppLogger.info('save(${item.title}) via $activeEngine', tag: _tag);
    final model = ContentModel.fromEntity(item);
    if (useNoSql) {
      await _noSqlDs.put(model);
    } else {
      await _sqlDs.insert(model);
    }
  }

  @override
  Future<void> update(ContentItem item) async {
    AppLogger.info('update(${item.title}) via $activeEngine', tag: _tag);
    final model = ContentModel.fromEntity(item);
    if (useNoSql) {
      await _noSqlDs.put(model);
    } else {
      await _sqlDs.update(model);
    }
  }

  @override
  Future<void> delete(String id) async {
    AppLogger.info('delete($id) via $activeEngine', tag: _tag);
    if (useNoSql) {
      await _noSqlDs.delete(id);
    } else {
      await _sqlDs.delete(id);
    }
  }

  @override
  Future<List<ContentItem>> getByType(ContentType type) async {
    AppLogger.debug('getByType(${type.name}) via $activeEngine', tag: _tag);
    return useNoSql ? _noSqlDs.getByType(type) : _sqlDs.getByType(type);
  }

  @override
  Future<List<ContentItem>> getByStatus(WatchStatus status) async {
    AppLogger.debug('getByStatus(${status.name}) via $activeEngine', tag: _tag);
    return useNoSql ? _noSqlDs.getByStatus(status) : _sqlDs.getByStatus(status);
  }

  @override
  Future<List<ContentItem>> getFavorites() async {
    AppLogger.debug('getFavorites() via $activeEngine', tag: _tag);
    return useNoSql ? _noSqlDs.getFavorites() : _sqlDs.getFavorites();
  }

  @override
  Future<List<ContentItem>> getRecent({int limit = 10}) async {
    AppLogger.debug('getRecent(limit=$limit) via $activeEngine', tag: _tag);
    return useNoSql
        ? _noSqlDs.getRecent(limit: limit)
        : _sqlDs.getRecent(limit: limit);
  }
}
