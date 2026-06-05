// test/repository_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:cinetrack/core/logger/app_logger.dart';
import 'package:cinetrack/data/datasources/local/nosql_datasource.dart';
import 'package:cinetrack/data/datasources/local/sql_datasource.dart';
import 'package:cinetrack/data/repositories/content_repository_impl.dart';
import 'package:cinetrack/data/models/content_model.dart';
import 'package:cinetrack/domain/entities/content_item.dart';

/// Stubs para pruebas (sin DB real en tests unitarios)
class _FakeSqlDs extends SqlDatasource {
  final List<ContentModel> _store = [];

  @override
  Future<void> insert(ContentModel model) async {
    AppLogger.debug('FakeSqlDs.insert: ${model.title}', tag: 'TEST');
    _store.add(model);
  }

  @override
  Future<void> update(ContentModel model) async {
    AppLogger.debug('FakeSqlDs.update: ${model.title}', tag: 'TEST');
    final idx = _store.indexWhere((e) => e.id == model.id);
    if (idx != -1) _store[idx] = model;
  }

  @override
  Future<void> delete(String id) async {
    _store.removeWhere((e) => e.id == id);
  }

  @override
  Future<List<ContentModel>> getAll() async => _store.toList();

  @override
  Future<ContentModel?> getById(String id) async {
    try {
      return _store.firstWhere((e) => e.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<ContentModel>> getByType(ContentType type) async {
    return _store.where((e) => e.type == type).toList();
  }

  @override
  Future<List<ContentModel>> getFavorites() async {
    return _store.where((e) => e.isFavorite).toList();
  }

  List<ContentModel> get store => _store;
}

class _FakeNoSqlDs extends NoSqlDatasource {
  final Map<String, ContentModel> _store = {};

  @override
  Future<void> put(ContentModel model) async {
    AppLogger.debug('FakeNoSqlDs.put: ${model.title}', tag: 'TEST');
    _store[model.id] = model;
  }

  @override
  Future<void> delete(String id) async {
    _store.remove(id);
  }

  @override
  Future<List<ContentModel>> getAll() async => _store.values.toList();

  @override
  Future<ContentModel?> getById(String id) async => _store[id];

  @override
  Future<List<ContentModel>> getByType(ContentType type) async {
    return _store.values.where((e) => e.type == type).toList();
  }

  @override
  Future<List<ContentModel>> getFavorites() async {
    return _store.values.where((e) => e.isFavorite).toList();
  }

  Map<String, ContentModel> get store => _store;
}

void main() {
  final sampleMovie = ContentItem(
    id: 'test-001',
    title: 'Inception',
    year: 2010,
    genre: 'Sci-Fi',
    description: 'Un ladrón de sueños.',
    posterUrl: '',
    type: ContentType.movie,
    status: WatchStatus.completed,
    rating: 5.0,
  );

  final sampleSeries = ContentItem(
    id: 'test-002',
    title: 'Breaking Bad',
    year: 2008,
    genre: 'Drama',
    description: 'Un profesor de química.',
    posterUrl: '',
    type: ContentType.series,
    status: WatchStatus.watching,
    currentSeason: 3,
    currentEpisode: 7,
  );

  late _FakeSqlDs sqlDs;
  late _FakeNoSqlDs noSqlDs;
  late ContentRepositoryImpl repo;

  setUp(() {
    sqlDs = _FakeSqlDs();
    noSqlDs = _FakeNoSqlDs();
    repo = ContentRepositoryImpl(
      sqlDatasource: sqlDs,
      noSqlDatasource: noSqlDs,
      useNoSql: false,
    );
  });

  test('Prueba 1: Escribe correctamente en SQLite (modo SQL)', () async {
    AppLogger.info('=== TEST 1: Escritura en SQL ===', tag: 'TEST');

    expect(repo.useNoSql, isFalse);

    await repo.save(sampleMovie);
    await repo.save(sampleSeries);

    expect(sqlDs.store.length, 2);
    expect(noSqlDs.store.length, 0);
    expect(sqlDs.store.first.title, 'Inception');

    AppLogger.info('TEST 1 PASADO ✅', tag: 'TEST');
  });

  test('Prueba 2: Conmutación a NoSQL y escritura independiente', () async {
    AppLogger.info('=== TEST 2: Conmutación de motor ===', tag: 'TEST');

    await repo.save(sampleMovie);
    repo.switchEngine(toNoSql: true);
    await repo.save(sampleSeries);

    expect(sqlDs.store.length, 1);
    expect(noSqlDs.store.length, 1);
    expect(noSqlDs.store['test-002']?.title, 'Breaking Bad');

    AppLogger.info('TEST 2 PASADO ✅', tag: 'TEST');
  });

  test('Prueba 3: Actualización de datos en el motor activo', () async {
    AppLogger.info('=== TEST 3: Actualización ===', tag: 'TEST');

    await repo.save(sampleMovie);
    final updatedMovie = sampleMovie.copyWith(title: 'Inception Redux', rating: 4.5);
    
    await repo.update(updatedMovie);

    final stored = await repo.getById(sampleMovie.id);
    expect(stored?.title, 'Inception Redux');
    expect(stored?.rating, 4.5);
    
    AppLogger.info('TEST 3 PASADO ✅', tag: 'TEST');
  });

  test('Prueba 4: Eliminación de datos en el motor activo', () async {
    AppLogger.info('=== TEST 4: Eliminación ===', tag: 'TEST');

    repo.switchEngine(toNoSql: true);
    await repo.save(sampleSeries);
    
    expect((await repo.getAll()).length, 1);
    
    await repo.delete(sampleSeries.id);
    
    expect((await repo.getAll()).length, 0);
    AppLogger.info('TEST 4 PASADO ✅', tag: 'TEST');
  });

  test('Prueba 5: Filtrado por tipo (Película/Serie)', () async {
    AppLogger.info('=== TEST 5: Filtrado por Tipo ===', tag: 'TEST');

    await repo.save(sampleMovie);
    await repo.save(sampleSeries);

    final movies = await repo.getByType(ContentType.movie);
    final series = await repo.getByType(ContentType.series);

    expect(movies.length, 1);
    expect(movies.first.title, 'Inception');
    expect(series.length, 1);
    expect(series.first.title, 'Breaking Bad');

    AppLogger.info('TEST 5 PASADO ✅', tag: 'TEST');
  });

  test('Prueba 6: Recuperación de Favoritos', () async {
    AppLogger.info('=== TEST 6: Favoritos ===', tag: 'TEST');

    final favMovie = sampleMovie.copyWith(id: 'fav-1', isFavorite: true);
    final nonFavMovie = sampleMovie.copyWith(id: 'fav-2', isFavorite: false);

    await repo.save(favMovie);
    await repo.save(nonFavMovie);

    final favorites = await repo.getFavorites();

    expect(favorites.length, 1);
    expect(favorites.first.id, 'fav-1');
    expect(favorites.first.isFavorite, isTrue);

    AppLogger.info('TEST 6 PASADO ✅', tag: 'TEST');
  });
}
