// lib/presentation/providers/content_provider.dart
import 'package:flutter/foundation.dart';
import '../../core/logger/app_logger.dart';
import '../../data/repositories/content_repository_impl.dart';
import '../../domain/entities/content_item.dart';

class ContentProvider extends ChangeNotifier {
  static const _tag = 'ContentProvider';

  final ContentRepositoryImpl _repository;

  ContentProvider(this._repository);

  List<ContentItem> _items = [];
  bool _isLoading = false;
  String? _error;

  List<ContentItem> get items => _items;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isNoSql => _repository.useNoSql;
  String get activeEngine => _repository.activeEngine;

  // ── Filtros derivados ────────────────────────────────────────
  List<ContentItem> get movies =>
      _items.where((e) => e.type == ContentType.movie).toList();

  List<ContentItem> get series =>
      _items.where((e) => e.type == ContentType.series).toList();

  List<ContentItem> get favorites =>
      _items.where((e) => e.isFavorite).toList();

  List<ContentItem> get pending =>
      _items.where((e) => e.status == WatchStatus.pending).toList();

  List<ContentItem> get watched =>
      _items.where((e) => e.status == WatchStatus.completed).toList();

  // ── Filtros con visibilidad mejorada ─────────────────────────
  List<ContentItem> get recentMovies {
    // Primero películas con fecha de vista, luego el resto, todo en orden inverso
    final list = List<ContentItem>.from(movies);
    list.sort((a, b) {
      if (a.watchedDate != null && b.watchedDate != null) {
        return b.watchedDate!.compareTo(a.watchedDate!);
      }
      if (a.watchedDate != null) return -1;
      if (b.watchedDate != null) return 1;
      return 0; // Si ninguna tiene fecha, mantenemos orden de lista
    });
    // Si no hay orden claro, invertimos la lista para que lo último agregado esté arriba
    return list.isEmpty ? [] : (movies.any((e) => e.watchedDate != null) ? list : movies.reversed.toList());
  }

  List<ContentItem> get recentSeries {
    final list = List<ContentItem>.from(series);
    list.sort((a, b) {
      if (a.watchedDate != null && b.watchedDate != null) {
        return b.watchedDate!.compareTo(a.watchedDate!);
      }
      if (a.status == WatchStatus.watching) return -1;
      if (b.status == WatchStatus.watching) return 1;
      return 0;
    });
    return list.isEmpty ? [] : (series.any((e) => e.watchedDate != null || e.status == WatchStatus.watching) ? list : series.reversed.toList());
  }

  // ── CRUD ────────────────────────────────────────────────────
  Future<void> loadAll() async {
    _setLoading(true);
    try {
      _items = await _repository.getAll();
      AppLogger.info('Cargados ${_items.length} items', tag: _tag);
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Error al cargar items: $e', tag: _tag);
    }
    _setLoading(false);
  }

  Future<void> addItem(ContentItem item) async {
    try {
      // 1. Actualización optimista: Clonamos la lista para forzar el rebuild de la UI
      _items = List<ContentItem>.from(_items)..add(item);
      _error = null;
      notifyListeners();
      
      // 2. Persistencia
      await _repository.save(item);
      
      // 3. Sincronización final con la base de datos (para obtener IDs generados o sorting real)
      final freshItems = await _repository.getAll();
      _items = List<ContentItem>.from(freshItems);
      notifyListeners();
      
      AppLogger.info('Item añadido y sincronizado: ${item.title}', tag: _tag);
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Error al añadir item: $e', tag: _tag);
      await loadAll(); // Revertimos al estado real de la DB en caso de fallo
    }
  }

  Future<void> updateItem(ContentItem item) async {
    try {
      final idx = _items.indexWhere((e) => e.id == item.id);
      if (idx != -1) {
        _items = List.from(_items)..[idx] = item;
        notifyListeners();
      }
      
      await _repository.update(item);
      await _silentLoadAll();
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Error al actualizar item: $e', tag: _tag);
      await loadAll();
    }
  }

  Future<void> deleteItem(String id) async {
    try {
      _items = _items.where((e) => e.id != id).toList();
      notifyListeners();
      
      await _repository.delete(id);
      await _silentLoadAll();
    } catch (e) {
      _error = e.toString();
      AppLogger.error('Error al eliminar item: $e', tag: _tag);
      await loadAll();
    }
  }

  Future<void> _silentLoadAll() async {
    try {
      _items = await _repository.getAll();
      notifyListeners();
    } catch (e) {
      AppLogger.error('Error en carga silenciosa: $e', tag: _tag);
    }
  }

  Future<void> toggleFavorite(ContentItem item) async {
    final updated = item.copyWith(isFavorite: !item.isFavorite);
    await updateItem(updated);
  }

  // ── Conmutación de motor ─────────────────────────────────────
  Future<void> switchEngine({required bool toNoSql}) async {
    _repository.switchEngine(toNoSql: toNoSql);
    await loadAll();
    notifyListeners();
  }

  void _setLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }
}
