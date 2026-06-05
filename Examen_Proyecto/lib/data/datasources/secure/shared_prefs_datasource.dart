// lib/data/datasources/secure/shared_prefs_datasource.dart
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/logger/app_logger.dart';

/// SharedPreferences — El mecanismo estándar y más antiguo de Android.
/// Almacena datos en un archivo XML en texto plano.
/// NO ES SEGURO para datos sensibles.
class SharedPrefsDatasource {
  static const _tag = 'SharedPrefsDatasource';
  static const _prefix = 'shared_';

  Future<void> save(String key, String value) async {
    final fullKey = '$_prefix$key';
    AppLogger.info('SharedPrefs.save → key="$fullKey" [TEXTO PLANO]', tag: _tag);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(fullKey, value);
    AppLogger.debug('SharedPrefs persistido en XML', tag: _tag);
  }

  Future<String?> get(String key) async {
    final fullKey = '$_prefix$key';
    AppLogger.info('SharedPrefs.get → key="$fullKey"', tag: _tag);
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(fullKey);
    if (value == null) {
      AppLogger.debug('SharedPrefs: clave "$fullKey" no encontrada', tag: _tag);
    } else {
      AppLogger.debug('SharedPrefs: clave "$fullKey" recuperada', tag: _tag);
    }
    return value;
  }

  Future<void> delete(String key) async {
    final fullKey = '$_prefix$key';
    AppLogger.info('SharedPrefs.delete → key="$fullKey"', tag: _tag);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(fullKey);
  }
}
