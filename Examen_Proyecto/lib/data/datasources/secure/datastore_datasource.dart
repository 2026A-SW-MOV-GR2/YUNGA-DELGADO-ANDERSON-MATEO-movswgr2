// lib/data/datasources/secure/datastore_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/logger/app_logger.dart';

/// DataStore (simulado en Flutter con SharedPreferences async).
///
/// En Android nativo, DataStore usa Kotlin Flows para evitar bloquear el
/// hilo principal. En Flutter, shared_preferences ya es completamente
/// asíncrono y cumple el mismo principio académico: nunca bloquea el UI thread.
///
/// Para una integración nativa real se usaría un MethodChannel hacia
/// androidx.datastore:datastore-preferences en el lado Android.
class DataStoreDatasource {
  static const _tag = 'DataStoreDatasource';
  static const _prefix = 'datastore_';

  Future<void> save(String key, String value) async {
    final fullKey = '$_prefix$key';
    AppLogger.info('DataStore.save → key="$fullKey"', tag: _tag);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(fullKey, value);
    AppLogger.debug('DataStore guardado (async, sin bloquear UI)', tag: _tag);
  }

  Future<String?> get(String key) async {
    final fullKey = '$_prefix$key';
    AppLogger.info('DataStore.get → key="$fullKey"', tag: _tag);
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(fullKey);
    if (value == null) {
      AppLogger.debug('DataStore: clave "$fullKey" no encontrada', tag: _tag);
    } else {
      AppLogger.debug('DataStore: clave "$fullKey" recuperada', tag: _tag);
    }
    return value;
  }

  Future<void> delete(String key) async {
    final fullKey = '$_prefix$key';
    AppLogger.info('DataStore.delete → key="$fullKey"', tag: _tag);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(fullKey);
  }
}