// lib/data/datasources/local/sql/sql_datasource.dart
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/logger/app_logger.dart';
import '../../../domain/entities/content_item.dart';
import '../../models/content_model.dart';

class SqlDatasource {
  static const _tag = 'SqlDatasource';
  static const _dbName = 'cinetrack.db';
  static const _version = 1;
  static const _table = 'content_items';

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDb();
    return _db!;
  }

  Future<Database> _initDb() async {
    AppLogger.info('Inicializando base de datos SQLite', tag: _tag);
    final path = join(await getDatabasesPath(), _dbName);
    return openDatabase(
      path,
      version: _version,
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    AppLogger.debug('Creando esquema SQL', tag: _tag);
    await db.execute('''
      CREATE TABLE $_table (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        year INTEGER NOT NULL,
        genre TEXT NOT NULL,
        description TEXT NOT NULL,
        posterUrl TEXT NOT NULL,
        type INTEGER NOT NULL,
        status INTEGER NOT NULL,
        watchedDate INTEGER,
        rating REAL NOT NULL DEFAULT 0.0,
        comment TEXT DEFAULT '',
        isFavorite INTEGER NOT NULL DEFAULT 0,
        currentSeason INTEGER,
        currentEpisode INTEGER
      )
    ''');
    AppLogger.info('Tabla $_table creada exitosamente', tag: _tag);
  }

  Future<List<ContentModel>> getAll() async {
    AppLogger.debug('getAll() desde SQLite', tag: _tag);
    final db = await database;
    // Quitamos el orden por título para mantener el orden de inserción
    final maps = await db.query(_table);
    return maps.map(ContentModel.fromMap).toList();
  }

  Future<ContentModel?> getById(String id) async {
    AppLogger.debug('getById($id) desde SQLite', tag: _tag);
    final db = await database;
    final maps = await db.query(_table, where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return ContentModel.fromMap(maps.first);
  }

  Future<void> insert(ContentModel model) async {
    AppLogger.info('INSERT SQLite: ${model.title}', tag: _tag);
    final db = await database;
    await db.insert(_table, model.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<void> update(ContentModel model) async {
    AppLogger.info('UPDATE SQLite: ${model.title}', tag: _tag);
    final db = await database;
    final rows = await db.update(
      _table, model.toMap(),
      where: 'id = ?', whereArgs: [model.id],
    );
    if (rows == 0) AppLogger.error('No se encontró registro para UPDATE: ${model.id}', tag: _tag);
  }

  Future<void> delete(String id) async {
    AppLogger.info('DELETE SQLite: $id', tag: _tag);
    final db = await database;
    await db.delete(_table, where: 'id = ?', whereArgs: [id]);
  }

  Future<List<ContentModel>> getByType(ContentType type) async {
    AppLogger.debug('getByType(${type.name}) desde SQLite', tag: _tag);
    final db = await database;
    final maps = await db.query(_table, where: 'type = ?', whereArgs: [type.index]);
    return maps.map(ContentModel.fromMap).toList();
  }

  Future<List<ContentModel>> getByStatus(WatchStatus status) async {
    AppLogger.debug('getByStatus(${status.name}) desde SQLite', tag: _tag);
    final db = await database;
    final maps = await db.query(_table, where: 'status = ?', whereArgs: [status.index]);
    return maps.map(ContentModel.fromMap).toList();
  }

  Future<List<ContentModel>> getFavorites() async {
    AppLogger.debug('getFavorites() desde SQLite', tag: _tag);
    final db = await database;
    final maps = await db.query(_table, where: 'isFavorite = 1');
    return maps.map(ContentModel.fromMap).toList();
  }

  Future<List<ContentModel>> getRecent({int limit = 10}) async {
    AppLogger.debug('getRecent(limit=$limit) desde SQLite', tag: _tag);
    final db = await database;
    final maps = await db.query(
      _table,
      where: 'watchedDate IS NOT NULL',
      orderBy: 'watchedDate DESC',
      limit: limit,
    );
    return maps.map(ContentModel.fromMap).toList();
  }

  Future<void> close() async {
    AppLogger.info('Cerrando conexión SQLite', tag: _tag);
    await _db?.close();
  }
}
