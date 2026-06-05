// lib/presentation/pages/network/network_page.dart
import 'package:flutter/material.dart';
import '../../../core/logger/app_logger.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/datasources/network/jsonplaceholder_service.dart';
import '../../../domain/entities/post_item.dart';

class NetworkPage extends StatefulWidget {
  const NetworkPage({super.key});

  @override
  State<NetworkPage> createState() => _NetworkPageState();
}

class _NetworkPageState extends State<NetworkPage> {
  final _service = JsonPlaceholderService();
  final _idController = TextEditingController(text: '1');
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  PostItem? _currentPost;
  bool _isLoadingGet = false;
  bool _isLoadingPut = false;
  String? _getStatus;
  String? _putStatus;
  bool _putSuccess = false;

  bool get _isBusy => _isLoadingGet || _isLoadingPut;

  @override
  void dispose() {
    _idController.dispose();
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  Future<void> _fetchPost() async {
    final id = int.tryParse(_idController.text.trim());
    if (id == null || id < 1 || id > 100) {
      setState(() => _getStatus = 'Ingresa un ID entre 1 y 100');
      return;
    }

    setState(() {
      _isLoadingGet = true;
      _getStatus = null;
      _putStatus = null;
      _putSuccess = false;
      _currentPost = null;
    });

    try {
      final post = await _service.getPost(id);
      setState(() {
        _currentPost = post;
        _titleController.text = post.title;
        _bodyController.text = post.body;
        _getStatus = '200 OK — Post #${post.id} cargado';
      });
      AppLogger.info('GET exitoso: post #$id', tag: 'NetworkPage');
    } catch (e) {
      setState(() => _getStatus = 'Error: $e');
      AppLogger.error('GET fallido: $e', tag: 'NetworkPage');
    } finally {
      setState(() => _isLoadingGet = false);
    }
  }

  Future<void> _updatePost() async {
    if (_currentPost == null) return;

    setState(() {
      _isLoadingPut = true;
      _putStatus = null;
      _putSuccess = false;
    });

    try {
      final updated = _currentPost!.copyWith(
        title: _titleController.text.trim(),
        body: _bodyController.text.trim(),
      );
      final result = await _service.updatePost(updated);
      setState(() {
        _currentPost = result;
        _putStatus = '200 OK — Post actualizado en el servidor';
        _putSuccess = true;
      });
      AppLogger.info('PUT exitoso: post #${result.id}', tag: 'NetworkPage');
    } catch (e) {
      setState(() {
        _putStatus = 'Error: $e';
        _putSuccess = false;
      });
      AppLogger.error('PUT fallido: $e', tag: 'NetworkPage');
    } finally {
      setState(() => _isLoadingPut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('REST API'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Chip(
              label: const Text('JSONPlaceholder'),
              backgroundColor: Colors.teal.withOpacity(0.15),
              side: const BorderSide(color: Colors.teal),
              labelStyle: const TextStyle(color: Colors.teal, fontSize: 11),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Módulo GET ───────────────────────────────────────
            _SectionCard(
              title: 'Consulta (GET)',
              icon: Icons.download_rounded,
              color: Colors.teal,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Ingresa un ID de post (1-100) para consultar el servidor',
                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _idController,
                          enabled: !_isBusy,
                          keyboardType: TextInputType.number,
                          style: const TextStyle(color: AppColors.white),
                          decoration: _inputDecoration('ID del Post (1-100)'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: _isBusy ? null : _fetchPost,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            disabledBackgroundColor: Colors.teal.withOpacity(0.3),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          icon: _isLoadingGet
                              ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.white),
                          )
                              : const Icon(Icons.search, color: AppColors.white),
                          label: Text(
                            _isLoadingGet ? 'Cargando...' : 'GET',
                            style: const TextStyle(color: AppColors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (_getStatus != null) ...[
                    const SizedBox(height: 12),
                    _StatusBanner(
                      message: _getStatus!,
                      isSuccess: _getStatus!.startsWith('200'),
                    ),
                  ],
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Módulo PUT ───────────────────────────────────────
            _SectionCard(
              title: 'Actualización (PUT)',
              icon: Icons.upload_rounded,
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Edita el contenido y envíalo de vuelta al servidor',
                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _titleController,
                    enabled: !_isBusy && _currentPost != null,
                    style: const TextStyle(color: AppColors.white),
                    decoration: _inputDecoration('Título'),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _bodyController,
                    enabled: !_isBusy && _currentPost != null,
                    maxLines: 4,
                    style: const TextStyle(color: AppColors.white),
                    decoration: _inputDecoration('Cuerpo del post'),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton.icon(
                      onPressed:
                      (_isBusy || _currentPost == null) ? null : _updatePost,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        disabledBackgroundColor:
                        AppColors.primary.withOpacity(0.3),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8)),
                      ),
                      icon: _isLoadingPut
                          ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: AppColors.white),
                      )
                          : const Icon(Icons.send, color: AppColors.white),
                      label: Text(
                        _isLoadingPut ? 'Enviando...' : 'PUT /posts/${_currentPost?.id ?? '?'}',
                        style: const TextStyle(color: AppColors.white),
                      ),
                    ),
                  ),
                  if (_putStatus != null) ...[
                    const SizedBox(height: 12),
                    _StatusBanner(
                      message: _putStatus!,
                      isSuccess: _putSuccess,
                    ),
                  ],
                  if (_currentPost == null)
                    const Padding(
                      padding: EdgeInsets.only(top: 12),
                      child: Text(
                        'Realiza primero un GET para habilitar la edición',
                        style: TextStyle(color: AppColors.grey, fontSize: 12),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Post actual ──────────────────────────────────────
            if (_currentPost != null)
              _SectionCard(
                title: 'Respuesta del Servidor',
                icon: Icons.code,
                color: Colors.purple,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _JsonRow('id', _currentPost!.id.toString()),
                    _JsonRow('userId', _currentPost!.userId.toString()),
                    _JsonRow('title', _currentPost!.title),
                    _JsonRow('body', _currentPost!.body),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: AppColors.grey),
    filled: true,
    fillColor: AppColors.surfaceLight,
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
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: BorderSide(color: AppColors.greyDark.withOpacity(0.4)),
    ),
  );
}

// ── Widgets auxiliares ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, color: color, size: 18),
            const SizedBox(width: 8),
            Text(title,
                style: TextStyle(
                    color: color,
                    fontSize: 15,
                    fontWeight: FontWeight.w700)),
          ]),
          const Divider(color: AppColors.greyDark, height: 20),
          child,
        ],
      ),
    );
  }
}

class _StatusBanner extends StatelessWidget {
  final String message;
  final bool isSuccess;

  const _StatusBanner({required this.message, required this.isSuccess});

  @override
  Widget build(BuildContext context) {
    final color = isSuccess ? Colors.green : Colors.redAccent;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(children: [
        Icon(isSuccess ? Icons.check_circle_outline : Icons.error_outline,
            color: color, size: 16),
        const SizedBox(width: 8),
        Expanded(
            child: Text(message,
                style: TextStyle(color: color, fontSize: 13))),
      ]),
    );
  }
}

class _JsonRow extends StatelessWidget {
  final String label;
  final String value;

  const _JsonRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(children: [
          TextSpan(
              text: '"$label": ',
              style: const TextStyle(
                  color: Colors.purple, fontSize: 12, fontWeight: FontWeight.w600)),
          TextSpan(
              text: '"$value"',
              style: const TextStyle(color: AppColors.grey, fontSize: 12)),
        ]),
      ),
    );
  }
}