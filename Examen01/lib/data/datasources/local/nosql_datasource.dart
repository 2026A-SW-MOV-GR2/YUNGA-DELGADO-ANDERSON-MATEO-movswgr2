// lib/data/datasources/local/nosql/nosql_datasource.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/content_item.dart';
import '../../models/content_model.dart';

class NoSqlDatasource {
  static const _tag = 'NoSqlDatasource';
  static const _boxName = 'content_items';

  Box? _box;

  Future<Box> get box async {
    if (_box == null || !(_box!.isOpen)) {
      AppLogger.info('Abriendo Hive Box: $_boxName', tag: _tag);
      _box = await Hive.openBox(_boxName);
    }
    return _box!;
  }

  Future<List<ContentModel>> getAll() async {
    AppLogger.debug('getAll() desde Hive (NoSQL)', tag: _tag);
    final b = await box;
    return b.values
        .map((v) => ContentModel.fromJson(Map<dynamic, dynamic>.from(v as Map)))
        .toList();
  }

  Future<ContentModel?> getById(String id) async {
    AppLogger.debug('getById($id) desde Hive', tag: _tag);
    final b = await box;
    final value = b.get(id);
    if (value == null) return null;
    return ContentModel.fromJson(Map<dynamic, dynamic>.from(value as Map));
  }

  Future<void> put(ContentModel model) async {
    AppLogger.info('PUT Hive: ${model.title}', tag: _tag);
    final b = await box;
    await b.put(model.id, model.toJson());
  }

  Future<void> delete(String id) async {
    AppLogger.info('DELETE Hive: $id', tag: _tag);
    final b = await box;
    await b.delete(id);
  }

  Future<List<ContentModel>> getByType(ContentType type) async {
    AppLogger.debug('getByType(${type.name}) desde Hive', tag: _tag);
    final all = await getAll();
    return all.where((e) => e.type == type).toList();
  }

  Future<List<ContentModel>> getByStatus(WatchStatus status) async {
    AppLogger.debug('getByStatus(${status.name}) desde Hive', tag: _tag);
    final all = await getAll();
    return all.where((e) => e.status == status).toList();
  }

  Future<List<ContentModel>> getFavorites() async {
    AppLogger.debug('getFavorites() desde Hive', tag: _tag);
    final all = await getAll();
    return all.where((e) => e.isFavorite).toList();
  }

  Future<List<ContentModel>> getRecent({int limit = 10}) async {
    AppLogger.debug('getRecent(limit=$limit) desde Hive', tag: _tag);
    final all = await getAll();
    final withDate = all.where((e) => e.watchedDate != null).toList()
      ..sort((a, b) => b.watchedDate!.compareTo(a.watchedDate!));
    return withDate.take(limit).toList();
  }

  Future<void> close() async {
    AppLogger.info('Cerrando Hive Box', tag: _tag);
    await _box?.close();
  }
}
