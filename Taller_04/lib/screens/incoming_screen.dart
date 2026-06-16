import 'dart:io';
import 'package:flutter/material.dart';

/// ─────────────────────────────────────────────────────────────
/// IncomingScreen — Módulo B: Acciones Entrantes
///
/// Recibe datos desde main.dart (vía MethodChannel → setState)
/// y los renderiza:
///   • Texto plano → Label con el contenido
///   • Imagen      → Imagen en pantalla completa del contenedor
///
/// Criterio de evaluación:
///   - Si llega imagen: limpiar área de texto / mostrar indicador
///   - Si llega texto:  limpiar área de imagen
///   - No debe crashear si la app ya estaba abierta
/// ─────────────────────────────────────────────────────────────
class IncomingScreen extends StatefulWidget {
  final String? incomingText;
  final String? incomingImagePath;

  const IncomingScreen({
    super.key,
    this.incomingText,
    this.incomingImagePath,
  });

  @override
  State<IncomingScreen> createState() => _IncomingScreenState();
}

class _IncomingScreenState extends State<IncomingScreen>
    with AutomaticKeepAliveClientMixin {
  // Guardamos los valores localmente para poder limpiarlos
  String? _displayText;
  String? _displayImagePath;

  // Tipo de dato actualmente mostrado
  _ContentType _contentType = _ContentType.waiting;

  @override
  bool get wantKeepAlive => true; // No re-construir al cambiar de tab

  @override
  void initState() {
    super.initState();
    _updateContent(widget.incomingText, widget.incomingImagePath);
  }

  @override
  void didUpdateWidget(IncomingScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // main.dart nos pasa nuevos datos → actualizamos sin crashear
    if (widget.incomingText != oldWidget.incomingText ||
        widget.incomingImagePath != oldWidget.incomingImagePath) {
      _updateContent(widget.incomingText, widget.incomingImagePath);
    }
  }

  void _updateContent(String? text, String? imagePath) {
    setState(() {
      if (imagePath != null) {
        // IMAGEN: limpiamos texto (criterio de evaluación)
        _displayImagePath = imagePath;
        _displayText = null;
        _contentType = _ContentType.image;
      } else if (text != null) {
        // TEXTO: limpiamos imagen (criterio de evaluación)
        _displayText = text;
        _displayImagePath = null;
        _contentType = _ContentType.text;
      } else {
        // Sin datos: estado de espera
        _displayText = null;
        _displayImagePath = null;
        _contentType = _ContentType.waiting;
      }
    });
  }

  void _clearContent() {
    setState(() {
      _displayText = null;
      _displayImagePath = null;
      _contentType = _ContentType.waiting;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Encabezado del módulo
          _buildHeader(),
          const SizedBox(height: 24),

          // ── Indicador de estado
          _buildStatusBadge(),
          const SizedBox(height: 20),

          // ── Área de texto recibido (Caso 1)
          _buildTextArea(),
          const SizedBox(height: 16),

          // ── Área de imagen recibida (Caso 2)
          _buildImageArea(),

          // ── Botón de limpiar (si hay datos)
          if (_contentType != _ContentType.waiting) ...[
            const SizedBox(height: 20),
            _buildClearButton(),
          ],

          // ── Instrucciones de uso
          const SizedBox(height: 28),
          _buildInstructions(),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────
  //  WIDGETS
  // ─────────────────────────────────────────────────────────

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: const Color(0xFF7C3AED).withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(
            Icons.download_rounded,
            color: Color(0xFFAB6EFF),
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'MÓDULO',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 2,
                color: Color(0xFF7C3AED),
              ),
            ),
            Text(
              'Acciones Entrantes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFFF0EEF6),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    final config = switch (_contentType) {
      _ContentType.waiting => (
          icon: Icons.radar_rounded,
          label: 'Esperando datos externos...',
          color: const Color(0xFF6B6880),
          bg: const Color(0xFF1A1A1F),
        ),
      _ContentType.text => (
          icon: Icons.chat_bubble_rounded,
          label: 'Texto recibido',
          color: const Color(0xFF10B981),
          bg: const Color(0xFF10B981).withOpacity(0.1),
        ),
      _ContentType.image => (
          icon: Icons.image_rounded,
          label: 'Imagen recibida',
          color: const Color(0xFFAB6EFF),
          bg: const Color(0xFF7C3AED).withOpacity(0.15),
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: config.bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: config.color.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(config.icon, color: config.color, size: 16),
          const SizedBox(width: 8),
          Text(
            config.label,
            style: TextStyle(
              color: config.color,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // CASO 1: Receptor de Chismes — texto plano
  Widget _buildTextArea() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF10B981).withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'text/plain',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF10B981),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Receptor de Chismes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF0EEF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Área de texto
            Container(
              width: double.infinity,
              constraints: const BoxConstraints(minHeight: 80),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFF0D0D0F),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: _contentType == _ContentType.text
                      ? const Color(0xFF10B981).withOpacity(0.5)
                      : const Color(0xFF2A2A35),
                ),
              ),
              child: _buildTextContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextContent() {
    if (_contentType == _ContentType.image) {
      // Criterio de evaluación: si hay imagen, el texto debe mostrar indicador
      return Row(
        children: const [
          Icon(Icons.image_rounded, color: Color(0xFF3A3A45), size: 16),
          SizedBox(width: 8),
          Text(
            'Dato actual es un archivo binario (imagen)',
            style: TextStyle(
              fontSize: 12,
              color: Color(0xFF3A3A45),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      );
    }

    if (_displayText != null) {
      return SelectableText(
        _displayText!,
        style: const TextStyle(
          fontSize: 14,
          color: Color(0xFFF0EEF6),
          height: 1.5,
        ),
      );
    }

    return const Text(
      'Aquí aparecerá el texto compartido desde otras apps\n(WhatsApp, navegador, YouTube, etc.)',
      style: TextStyle(
        fontSize: 12,
        color: Color(0xFF3A3A45),
        fontStyle: FontStyle.italic,
        height: 1.5,
      ),
    );
  }

  // CASO 2: Lector de Imágenes
  Widget _buildImageArea() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'image/*',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFFAB6EFF),
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'Lector de Imágenes',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFF0EEF6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Contenedor dinámico para imagen
            _buildImageContainer(),
          ],
        ),
      ),
    );
  }

  Widget _buildImageContainer() {
    if (_displayImagePath != null) {
      final file = File(_displayImagePath!);

      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: file.existsSync()
            ? Image.file(
                file,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _buildImagePlaceholder(isError: true),
              )
            : _buildImagePlaceholder(isError: true),
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder({bool isError = false}) {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        color: const Color(0xFF0D0D0F),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isError
              ? const Color(0xFFDC2626).withOpacity(0.4)
              : const Color(0xFF2A2A35),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isError ? Icons.broken_image_outlined : Icons.add_photo_alternate_outlined,
            color: const Color(0xFF2A2A35),
            size: 40,
          ),
          const SizedBox(height: 10),
          Text(
            isError
                ? 'No se pudo cargar la imagen'
                : 'Comparte una imagen desde\nla Galería o Google Fotos',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF3A3A45),
              fontStyle: FontStyle.italic,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearButton() {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: _clearContent,
        icon: const Icon(Icons.clear_rounded, size: 16),
        label: const Text('Limpiar datos recibidos'),
        style: OutlinedButton.styleFrom(
          foregroundColor: const Color(0xFF6B6880),
          side: const BorderSide(color: Color(0xFF2A2A35)),
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7C3AED).withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF7C3AED).withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'CÓMO USAR',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              letterSpacing: 2,
              color: Color(0xFF7C3AED),
            ),
          ),
          const SizedBox(height: 12),
          _buildStep('1', 'Abre la Galería nativa del teléfono'),
          _buildStep('2', 'Selecciona una foto y presiona Compartir'),
          _buildStep('3', 'Elige "SnapShare" de la lista de apps'),
          _buildStep('4', 'La imagen aparece aquí automáticamente'),
          const Divider(color: Color(0xFF2A2A35), height: 20),
          _buildStep('•', 'También funciona desde WhatsApp, navegador o YouTube (texto)'),
        ],
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.2),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              number,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Color(0xFFAB6EFF),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontSize: 13,
                color: Color(0xFF9E9AB5),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Enum para el estado del módulo entrante
enum _ContentType { waiting, text, image }
