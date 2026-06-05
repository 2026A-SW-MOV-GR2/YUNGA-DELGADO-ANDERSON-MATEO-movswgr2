// lib/data/datasources/secure/encrypted_prefs_datasource.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../../core/logger/app_logger.dart';

/// EncryptedSharedPreferences — Equivalente Flutter a EncryptedSharedPreferences de Android.
///
/// flutter_secure_storage usa:
///   - Android: EncryptedSharedPreferences con AES-256 SIV (llaves) + AES-128 GCM (valores)
///              respaldado por Android Keystore System.
///   - iOS:     Keychain Services.
///
/// Los datos se cifran automáticamente antes de escribirse en disco.
/// Ideal para tokens JWT, credenciales, API keys y datos confidenciales.
class EncryptedPrefsDatasource {
  static const _tag = 'EncryptedPrefsDatasource';

  // Opciones Android: usa EncryptedSharedPreferences internamente
  static const _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  final FlutterSecureStorage _storage;

  EncryptedPrefsDatasource()
      : _storage = const FlutterSecureStorage(
    aOptions: _androidOptions,
  );

  Future<void> save(String key, String value) async {
    AppLogger.info('EncryptedPrefs.save → key="$key" [CIFRADO AES-256]',
        tag: _tag);
    await _storage.write(key: key, value: value);
    AppLogger.debug('Secreto cifrado y persistido en disco', tag: _tag);
  }

  Future<String?> get(String key) async {
    AppLogger.info('EncryptedPrefs.get → key="$key"', tag: _tag);
    final value = await _storage.read(key: key);
    if (value == null) {
      AppLogger.debug('EncryptedPrefs: clave "$key" no encontrada', tag: _tag);
    } else {
      AppLogger.debug('EncryptedPrefs: secreto recuperado y descifrado',
          tag: _tag);
    }
    return value;
  }

  Future<void> delete(String key) async {
    AppLogger.info('EncryptedPrefs.delete → key="$key"', tag: _tag);
    await _storage.delete(key: key);
  }
}