// lib/presentation/pages/secrets/secrets_page.dart
import 'package:flutter/material.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/secure/datastore_datasource.dart';
import '../../../data/datasources/secure/encrypted_prefs_datasource.dart';
import '../../../data/datasources/secure/shared_prefs_datasource.dart';

enum _StorageType { sharedPrefs, dataStore, encryptedPrefs }

class SecretsPage extends StatefulWidget {
  const SecretsPage({super.key});

  @override
  State<SecretsPage> createState() => _SecretsPageState();
}

class _SecretsPageState extends State<SecretsPage> {
  final _sharedDs = SharedPrefsDatasource();
  final _datastoreDs = DataStoreDatasource();
  final _encryptedDs = EncryptedPrefsDatasource();

  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  _StorageType _selectedStorage = _StorageType.encryptedPrefs;
  bool _isLoading = false;
  String? _result;
  bool _resultIsError = false;

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final key = _keyController.text.trim();
    final value = _valueController.text.trim();

    if (key.isEmpty || value.isEmpty) {
      _showResult('Ingresa una llave y un valor', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      switch (_selectedStorage) {
        case _StorageType.sharedPrefs:
          await _sharedDs.save(key, value);
          break;
        case _StorageType.dataStore:
          await _datastoreDs.save(key, value);
          break;
        case _StorageType.encryptedPrefs:
          await _encryptedDs.save(key, value);
          break;
      }
      _showResult('✅ Guardado en ${_storageName(_selectedStorage)}');
      AppLogger.info('Secreto guardado: key="$key" en ${_storageName(_selectedStorage)}',
          tag: 'SecretsPage');
    } catch (e) {
      _showResult('Error al guardar: $e', isError: true);
      AppLogger.error('Error al guardar secreto: $e', tag: 'SecretsPage');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _retrieve() async {
    final key = _keyController.text.trim();

    if (key.isEmpty) {
      _showResult('Ingresa una llave para recuperar', isError: true);
      return;
    }

    setState(() => _isLoading = true);
    try {
      String? value;
      switch (_selectedStorage) {
        case _StorageType.sharedPrefs:
          value = await _sharedDs.get(key);
          break;
        case _StorageType.dataStore:
          value = await _datastoreDs.get(key);
          break;
        case _StorageType.encryptedPrefs:
          value = await _encryptedDs.get(key);
          break;
      }

      if (value == null) {
        _showResult('Clave "$key" no existe en ${_storageName(_selectedStorage)}',
            isError: true);
        AppLogger.debug('Clave "$key" no encontrada', tag: 'SecretsPage');
      } else {
        _showResult('🔑 "$key" → "$value"');
        _valueController.text = value;
        AppLogger.info('Secreto recuperado: key="$key"', tag: 'SecretsPage');
      }
    } catch (e) {
      _showResult('Error al recuperar: $e', isError: true);
      AppLogger.error('Error al recuperar secreto: $e', tag: 'SecretsPage');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showResult(String message, {bool isError = false}) {
    setState(() {
      _result = message;
      _resultIsError = isError;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Almacenamiento Seguro')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Selector de mecanismo ────────────────────────────
            const Text('Compartimento de almacenamiento',
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            ..._StorageType.values.map((type) => _StorageOption(
              type: type,
              selected: _selectedStorage == type,
              onTap: () => setState(() {
                _selectedStorage = type;
                _result = null;
              }),
            )),

            const SizedBox(height: 24),

            // ── Formulario ───────────────────────────────────────
            const Text('Llave / Valor',
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _SecretField(
              controller: _keyController,
              label: 'Llave (key)',
              icon: Icons.key,
              enabled: !_isLoading,
            ),
            const SizedBox(height: 12),
            _SecretField(
              controller: _valueController,
              label: 'Valor (value)',
              icon: Icons.lock_outline,
              enabled: !_isLoading,
              obscure: _selectedStorage == _StorageType.encryptedPrefs,
            ),

            const SizedBox(height: 20),

            // ── Botones ──────────────────────────────────────────
            Row(children: [
              Expanded(
                child: _ActionButton(
                  label: 'Guardar',
                  icon: Icons.save_outlined,
                  color: _storageColor(_selectedStorage),
                  loading: _isLoading,
                  onPressed: _save,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  label: 'Recuperar',
                  icon: Icons.search,
                  color: Colors.teal,
                  loading: _isLoading,
                  onPressed: _retrieve,
                  outlined: true,
                ),
              ),
            ]),

            // ── Resultado ────────────────────────────────────────
            if (_result != null) ...[
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: _resultIsError
                      ? Colors.red.withOpacity(0.1)
                      : Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: _resultIsError
                        ? Colors.red.withOpacity(0.4)
                        : Colors.green.withOpacity(0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      _resultIsError ? Icons.error_outline : Icons.check_circle_outline,
                      color: _resultIsError ? Colors.red : Colors.green,
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        _result!,
                        style: TextStyle(
                          color: _resultIsError ? Colors.red[300] : Colors.green[300],
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: 32),

            // ── Tabla informativa ────────────────────────────────
            const Text('Comparativa de Mecanismos',
                style: TextStyle(
                    color: AppColors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
            const SizedBox(height: 12),
            _ComparisonTable(),
          ],
        ),
      ),
    );
  }

  String _storageName(_StorageType t) {
    switch (t) {
      case _StorageType.sharedPrefs: return 'SharedPreferences';
      case _StorageType.dataStore: return 'DataStore';
      case _StorageType.encryptedPrefs: return 'EncryptedSharedPreferences';
    }
  }

  Color _storageColor(_StorageType t) {
    switch (t) {
      case _StorageType.sharedPrefs: return Colors.orange;
      case _StorageType.dataStore: return Colors.blue;
      case _StorageType.encryptedPrefs: return Colors.green;
    }
  }
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _StorageOption extends StatelessWidget {
  final _StorageType type;
  final bool selected;
  final VoidCallback onTap;

  const _StorageOption(
      {required this.type, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final data = _storageData(type);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: selected ? data.color.withOpacity(0.1) : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? data.color : AppColors.greyDark,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: data.color.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, color: data.color, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(data.name,
                    style: TextStyle(
                        color: selected ? data.color : AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 14)),
                Text(data.subtitle,
                    style: const TextStyle(
                        color: AppColors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (selected)
            Icon(Icons.radio_button_checked, color: data.color, size: 20)
          else
            const Icon(Icons.radio_button_unchecked,
                color: AppColors.greyDark, size: 20),
        ]),
      ),
    );
  }

  _StorageData _storageData(_StorageType t) {
    switch (t) {
      case _StorageType.sharedPrefs:
        return _StorageData(
          name: 'SharedPreferences',
          subtitle: 'Texto plano · XML · Sin cifrado',
          icon: Icons.lock_open,
          color: Colors.orange,
        );
      case _StorageType.dataStore:
        return _StorageData(
          name: 'DataStore',
          subtitle: 'Async · Reactivo · Sin bloquear UI',
          icon: Icons.storage,
          color: Colors.blue,
        );
      case _StorageType.encryptedPrefs:
        return _StorageData(
          name: 'EncryptedSharedPreferences',
          subtitle: 'AES-256 SIV + AES-128 GCM · Keystore',
          icon: Icons.security,
          color: Colors.green,
        );
    }
  }
}

class _StorageData {
  final String name, subtitle;
  final IconData icon;
  final Color color;
  _StorageData(
      {required this.name,
        required this.subtitle,
        required this.icon,
        required this.color});
}

class _SecretField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool enabled;
  final bool obscure;

  const _SecretField({
    required this.controller,
    required this.label,
    required this.icon,
    this.enabled = true,
    this.obscure = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      enabled: enabled,
      obscureText: obscure,
      style: const TextStyle(color: AppColors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: AppColors.grey),
        prefixIcon: Icon(icon, color: AppColors.grey, size: 18),
        filled: true,
        fillColor: AppColors.surface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyDark),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.greyDark),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.teal),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onPressed;
  final bool outlined;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onPressed,
    this.outlined = false,
  });

  @override
  Widget build(BuildContext context) {
    final style = outlined
        ? OutlinedButton.styleFrom(
      foregroundColor: color,
      side: BorderSide(color: color),
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minimumSize: const Size(double.infinity, 48),
    )
        : ElevatedButton.styleFrom(
      backgroundColor: color,
      shape:
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      minimumSize: const Size(double.infinity, 48),
    );

    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (loading)
          SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: outlined ? color : AppColors.white))
        else
          Icon(icon, size: 18, color: outlined ? color : AppColors.white),
        const SizedBox(width: 8),
        Text(label,
            style: TextStyle(
                color: outlined ? color : AppColors.white,
                fontWeight: FontWeight.w600)),
      ],
    );

    return outlined
        ? OutlinedButton(onPressed: loading ? null : onPressed, style: style, child: child)
        : ElevatedButton(onPressed: loading ? null : onPressed, style: style, child: child);
  }
}

class _ComparisonTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.greyDark),
      ),
      child: Table(
        columnWidths: const {
          0: FlexColumnWidth(2),
          1: FlexColumnWidth(1.5),
          2: FlexColumnWidth(2),
        },
        border: TableBorder(
          horizontalInside: BorderSide(color: AppColors.greyDark, width: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        children: [
          _tableHeader(),
          _tableRow('SharedPreferences', 'Ninguna', 'Config UI / Flags', Colors.orange),
          _tableRow('DataStore', 'Ninguna', 'Async / Reactivo', Colors.blue),
          _tableRow('EncryptedSharedPref', 'AES-256', 'Tokens / Credenciales', Colors.green),
        ],
      ),
    );
  }

  TableRow _tableHeader() {
    return TableRow(
      decoration: const BoxDecoration(color: AppColors.surfaceLight),
      children: ['Mecanismo', 'Cifrado', 'Uso'].map((h) => Padding(
        padding: const EdgeInsets.all(10),
        child: Text(h,
            style: const TextStyle(
                color: AppColors.grey,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5)),
      )).toList(),
    );
  }

  TableRow _tableRow(String name, String enc, String use, Color color) {
    return TableRow(children: [
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(name,
            style: TextStyle(
                color: color, fontSize: 12, fontWeight: FontWeight.w600)),
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(enc,
            style: const TextStyle(color: AppColors.white, fontSize: 12)),
      ),
      Padding(
        padding: const EdgeInsets.all(10),
        child: Text(use,
            style: const TextStyle(color: AppColors.grey, fontSize: 12)),
      ),
    ]);
  }
}